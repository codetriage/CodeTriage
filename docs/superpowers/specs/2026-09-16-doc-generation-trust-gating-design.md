# Trust-gating for YARD doc generation

- **Date:** 2026-09-16
- **Status:** Draft — pending review
- **Scope:** Anti-abuse *trust-gating* for the doc-generation pipeline. Execution hardening (sandboxing the clone/parse, `.yardopts`/plugin loading) is explicitly **out of scope** — that track is handled separately and is already fixed on `main`.

## Problem

Doc generation is triggered whenever a repo is Ruby **and** `docs_subscriber_count > 0`
(`lib/tasks/schedule.rake:16`, `Repo#populate_docs!` at `app/models/repo.rb:65-68`).
`docs_subscriber_count` counts any `repo_subscription` with `read = true OR write = true`
(`Repo#query_docs_subscriber_count`, `repo.rb:259-268`).

That is a one-time, low bar: **one account + one subscription** flips generation on, and the
recurring scheduler then clones the repo and runs YARD **forever** with no re-check of intent.
The attacker pays once and extracts value indefinitely; an abandoned but legitimate repo keeps
consuming compute forever too.

## Goals

1. **Raise the cost to *turn on* doc generation** so a fresh throwaway account can't do it — a
   drive-by is blocked, and even a patient attacker must age an account.
2. **Wind generation down automatically** when no one is actually engaging with a repo's docs,
   and offer a one-click path back on ("re-opt-in"). This forces *ongoing* cost on an attacker
   and reclaims compute from dead repos.
3. **A global kill switch** for incident response.

## Non-goals

- Execution/blast-radius hardening (clone limits, timeouts, sandboxing, tmp cleanup, retry caps).
  Out of scope; tracked separately.
- Per-account rate caps and IP-based Sybil resistance (see *Future work*).

## Design overview

One coherent notion of "trust", enforced at two layers.

A repo's doc-generation status becomes:

| State | Condition | Scheduler |
|---|---|---|
| Unsupported | `!can_doctor_docs?` (non-Ruby) | skip (today's behavior) |
| Awaiting a qualified subscriber | Ruby, **0 active doc subscriptions** | skip |
| Active | ≥1 active doc subscription | generate |
| Paused (inactivity) | had doc subs, none currently active | skip (emergent — see below) |
| Globally disabled | kill switch set | skip everything |

The liveness data that decides "active" lives **on the subscription** (`repo_subscriptions`),
because a doc click is by a specific user on a specific repo — it belongs to the association, not
the repo. The repo-level "should the job run" decision is *derived* from aggregating that
subscription data into the existing `docs_subscriber_count` column.

## Feature 1 — Entry gate

### Layer 1 — hard block at subscribe time (new)

A `RepoSubscription` validation refuses to **enable docs** (make the subscription a doc
subscription — `read` or `write`) unless:

> the subscriber's account age ≥ **7 days**, **OR** the repo already has ≥1 **other active** doc
> subscription.

- "active doc subscription" = a `repo_subscription` for the repo with `read || write` **and**
  `docs_last_click_at > DOC_ACTIVITY_WINDOW.ago`, excluding the subject's own record.
  ("Active" is the liveness sense, deliberately **not** "any existing doc sub" — this closes a
  revival bypass: a fresh account cannot resurrect a repo whose doc subs have all gone dormant.)
- **Scoped to the doc opt-in only.** A `<7d` account can still subscribe for **issue** triage;
  it just can't turn on docs.
- **Effect:** the *first* doc subscriber on any repo must be a ≥7-day-old account. Fresh accounts
  can only pile onto repos that are already doc-active. This eliminates the fresh-account
  self-bootstrap. A patient attacker must age an account 7 days to bootstrap one repo; the 7-day
  cooldown plus the deliberate act of opting into docs is itself the "real user" signal (so no
  separate `sign_in_count`/activity check is used at entry).

**Enforcement details / gotchas:**

- Enforce as a **model validation**, not only controller logic —
  `RepoSubscriptionsController#create`/`#update` already treat a failed `save` as an error and
  re-render with a flash (`repo_subscriptions_controller.rb:6-32`), so a validation is the
  bypass-proof seam and needs no controller restructuring.
- `RepoSubscription#set_read_write` runs in a **`before_save`** callback (`repo_subscription.rb:18`),
  i.e. *after* validation. So at validation time `read`/`write` may not yet reflect the incoming
  limits. The validation must compute doc-intent from the incoming `read_limit`/`write_limit`
  (mirroring `set_read_write`: doc sub ⇔ a limit is present and non-zero), not from the `read`/
  `write` booleans.
- The gate applies only when a subscription is **newly becoming** a doc sub (was not already
  `read || write` in the database). An existing doc sub merely updating its limits is not
  re-gated, and disabling docs is never gated.

### Layer 2 — job-run gate (derived)

`docs_subscriber_count` is **redefined** to mean *count of active doc subscriptions*.
`Repo#query_docs_subscriber_count` gains an activity predicate:

```sql
SELECT count(*)
FROM repo_subscriptions
WHERE repo_id = :repo_id
  AND (read = true OR write = true)
  AND docs_last_click_at > :active_since   -- DOC_ACTIVITY_WINDOW.ago
```

It is recomputed where it already is — `Repo#force_issues_count_sync!` (`repo.rb:155-160`), run
daily from `schedule:mark_closed`. **No change is needed to `schedule:process_repos` or
`populate_docs!`**: their existing `docs_subscriber_count > 0` checks now transparently mean
"≥1 active doc subscription."

`docs_subscriber_count` is **not** displayed to users anywhere (verified: it appears only as a
boolean gate in `_docs.html.slim:3`, the scheduler, and the model), so redefining it in place is
safe — no parallel column required.

## Feature 2 — Per-subscription inactivity + one-click re-opt-in

### New columns on `repo_subscriptions`

- `docs_last_click_at:datetime` — per-user, per-repo doc-click liveness.
- `docs_reopt_in_sent_at:datetime` — de-dupes the re-opt-in email (send once per inactivity
  episode).

Two dedicated columns are needed because `doc_assignments` has **no `clicked_at`** and its
`updated_at` reflects only the *first* click (the controller does `update(clicked: true)`
unconditionally, so re-clicks are no-ops). `users.last_clicked_at` is unusable as a signal — a
`before_save` sets it to `Time.now` for every user, so it is never null.

### Liveness tracking

- Both click actions in `DocMethodsController` (`click_method_redirect:26`,
  `click_source_redirect:44`) — which already load the `sub` — set
  `sub.docs_last_click_at = Time.now` and clear `sub.docs_reopt_in_sent_at`.
- On doc-subscription creation, `docs_last_click_at` is seeded to `Time.now`. **This seeding is
  the grace period**: a freshly created (or reactivated) doc sub counts as active for a full
  window without needing a click yet. No separate grace column.

A doc subscription is **active** ⇔ `read || write` **and**
`docs_last_click_at > DOC_ACTIVITY_WINDOW.ago`.

### Pause is emergent

When every doc subscription on a repo goes inactive, the derived `docs_subscriber_count` drops to
0 and generation simply stops. There is **no repo-level pause flag** — "paused" is derivable
(has doc subs, none active) for UI purposes only.

### Scope: this gates *generation*, not *sending*

Inactivity gates the **generation** job (`PopulateDocsJob`), which is where the compute/abuse
cost is. It does not, in the MVP, change the doc-*email* pipeline
(`DocMailerMaker` / `daily_docs`). For the common abuse case (a lone subscriber) this is moot —
when that sub goes inactive there is no one to email. For a multi-subscriber repo where some subs
are active and one is not, the inactive user keeps receiving doc emails drawn from *already
generated* `DocMethod`s until that assignable pool is exhausted, at which point their doc emails
taper off naturally. See *Open questions* for whether to also gate sending.

### Sweep + re-opt-in email

- New rake task `schedule:pause_inactive_docs` (daily, added to Heroku Scheduler like the other
  `schedule:*` tasks). Its logic lives in testable scopes on `RepoSubscription`
  (e.g. `inactive_docs_needing_reopt_in`: `read||write`, `docs_last_click_at <= WINDOW.ago`,
  `docs_reopt_in_sent_at IS NULL`). For each such subscription it enqueues the re-opt-in mailer
  and stamps `docs_reopt_in_sent_at = now`.
- New `UserMailer#resume_docs(repo_subscription:)` + template
  `app/views/user_mailer/resume_docs.md.erb`, mirroring `daily_docs`
  (`user_mailer.rb:61-68`, delivered `deliver_later` on the `mailers` queue).
- The email's resume link uses `repo_subscription.signed_id(purpose: :resume_docs,
  expires_in: 30.days)` — tamper-proof, no new token column, and appropriate for a low-stakes
  public-repo action. (The app has no signed-URL convention today; this introduces the modern
  Rails default rather than the legacy random-token-column pattern.)
- New `resume` action (on `RepoSubscriptionsController`, with `authenticate_user!` skipped for it
  since the signed id is the capability, or a small dedicated controller) →
  `RepoSubscription.find_signed(..., purpose: :resume_docs)` → reactivate
  (`docs_last_click_at = now`, `docs_reopt_in_sent_at = nil`) → redirect to the repo with a flash.
  Reactivation makes the sub count as active again on the next `mark_closed`, resuming generation.

**Trade-off (accepted):** activity is measured purely per-subscription doc-clicks (no user-level
login check). A doc subscriber who receives doc emails but never clicks for a full window is
paused and emailed a one-click resume — the correct, cheaper outcome. It also means a patient
attacker can *sustain* one bootstrapped repo by clicking a doc within each window, which is
ongoing manual cost by design.

## Feature 3 — Global kill switch

No feature-flag library exists; `ENV` is the app's idiom (`ENV["…"]` / `ENV.fetch`). Add an
early return guarded by `ENV["DISABLE_DOC_GENERATION"]` in **both**:

- `schedule:process_repos` — so nothing is enqueued, and
- `Repo#populate_docs!` — so in-flight jobs short-circuit (returns a `"Skipped, generation
  disabled"` string, consistent with its existing skip returns).

Flipped via `heroku config:set DISABLE_DOC_GENERATION=1` (restarts dynos — acceptable for
incident response). Defaults to enabled.

## UI wording

All in `app/views/repos/show.html.slim` (the "Triage Docs!" CTA + doc opt-in form at ~`:42-50`)
and `app/views/repos/_docs.html.slim:3` (the docs-tab empty state). Copy below is placeholder for
Schneems to finalize:

- **Awaiting a qualified subscriber** (Ruby, no active doc subs): "Doc suggestions turn on once
  this repo has an established subscriber."
- **Current user blocked by the 7-day gate**: disable the doc read/write form controls and show
  "You can turn on docs once your account is 7 days old, or if this repo already has active doc
  subscribers."
- **Paused for inactivity** (doc subs exist, none active): "Doc suggestions are paused because no
  one's engaged recently — click a doc, or use the re-enable link we emailed you."

## Data model changes

| Change | Detail |
|---|---|
| Add column | `repo_subscriptions.docs_last_click_at :datetime` |
| Add column | `repo_subscriptions.docs_reopt_in_sent_at :datetime` |
| Redefine (no schema change) | `repos.docs_subscriber_count` = count of *active* doc subscriptions |
| Backfill | set `docs_last_click_at = now` for all existing `read||write` subscriptions |

No new columns on `repos`. No parallel count column.

## Constants (tunable)

On `RepoSubscription` (env-overridable if desired):

- `DOC_SUBSCRIBE_MIN_ACCOUNT_AGE = 7.days`
- `DOC_ACTIVITY_WINDOW = 60.days`

Entry threshold is **1** active doc subscription to run (quality over count — raising it would
kill the long tail of legit single-fan repos).

## Testing (minitest, `test/`)

- `RepoSubscription` validation matrix: `<7d` + no active others → blocked; `<7d` + an active
  other → allowed; `≥7d` → allowed; existing doc sub updating limits → not blocked; disabling docs
  → not blocked.
- `Repo#query_docs_subscriber_count` counts only *active* doc subs (recent vs. stale
  `docs_last_click_at`).
- `DocMethodsController` click actions set `docs_last_click_at` and clear `docs_reopt_in_sent_at`.
- `RepoSubscription` sweep scopes + the `resume` action (valid/expired/tampered signed id).
- `UserMailer#resume_docs` renders and links via signed id.
- Kill switch: `populate_docs!` short-circuits when `ENV["DISABLE_DOC_GENERATION"]` is set;
  `schedule:process_repos` enqueues nothing.

## Rollout

1. Migration adds the two columns and backfills `docs_last_click_at = now`. Because everything is
   seeded active, the redefined count equals the old count immediately after deploy — **nothing
   pauses on day one**. Repos wind down only as subs age past the window without clicks (gradual,
   observable).
2. Add the Heroku Scheduler entry for `rake schedule:pause_inactive_docs` (daily; external config,
   like the other schedule tasks).
3. Kill switch ships defaulting to enabled.
4. Fully reversible by loosening the constants.

## Security analysis

- **Before:** 1 fresh account + 1 subscription → instant, perpetual generation on an
  attacker-controlled repo.
- **After:**
  - A fresh account **cannot opt into docs at all** on a repo that isn't already doc-active
    (hard 7-day gate).
  - Generation runs only while ≥1 subscriber has clicked a doc within the window; abandoned and
    attacker repos **auto-wind-down** at the window boundary.
  - Reviving a wound-down repo requires a ≥7-day account or a genuinely active co-subscriber.
  - Global kill switch for incidents.
- **Residual (accepted):** a patient attacker who ages one account 7 days can bootstrap one repo
  and sustain it by clicking a doc within each window (ongoing manual cost). Multi-repo abuse
  requires multiple aged accounts. Execution hardening is a separate, already-addressed track.

## Open questions for review

1. **Gate sending too, or only generation?** MVP gates generation only (above). Optionally, the
   doc-email path could also skip inactive subs so the "paused" message is literally true for that
   user. Small extra change (a filter in the send path); recommended only if the natural taper
   above feels insufficient.
2. **Resume link auth.** Confirmed approach is an unauthenticated signed-id link (the signed id is
   the capability). If you'd rather require login on resume, that's a one-line change but adds
   friction from an email click.

## Future work

- Per-account cap on how many repos can be doc-enabled per time window.
- Distinct-IP / Sybil resistance on the "active others" check.
- Tune `DOC_ACTIVITY_WINDOW` and the account-age threshold from observed data.
