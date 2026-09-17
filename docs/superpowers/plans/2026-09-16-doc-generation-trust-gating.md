# Doc-generation Trust-gating Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop a fresh throwaway account from switching on perpetual YARD doc generation, wind generation down automatically when no one engages with a repo's docs (with a one-click path back on), and add a global kill switch.

**Architecture:** One notion of "trust" enforced at two layers. Layer 1 is a hard `RepoSubscription` validation that refuses to *enable docs* unless the account is ≥7 days old or the repo already has an active doc subscriber. Layer 2 redefines the existing `docs_subscriber_count` gate to mean "count of *active* doc subscriptions", where "active" is decided by per-subscription doc-click liveness (`repo_subscriptions.docs_last_click_at`). A daily sweep emails a signed-id re-opt-in link to subscriptions that have gone quiet. An `ENV` kill switch short-circuits both the scheduler and the job.

**Tech Stack:** Ruby on Rails 8.1, PostgreSQL, minitest (`fixtures :all`, mocha, Capybara/rack-test), ActiveJob (`:test` adapter in test), Devise, Rails signed_id (`find_signed`).

**Spec:** `docs/superpowers/specs/2026-09-16-doc-generation-trust-gating-design.md` — the plan argues from this spec; executors should read both.

## Global Constraints

- **Test runner:** full suite is `bin/rake test` (matches CI). Focused run: `bin/rails test <path> -n <test_name>` (or `-n "/pattern/"`).
- **Lint:** `bundle exec standardrb` must pass. Run `bundle exec standardrb --fix` to autoformat before committing. New `.rb` files start with `# frozen_string_literal: true`; double-quoted strings; 2-space indent. (This repo already uses `has_`-prefixed predicates, e.g. `has_favorite_languages?`, so `has_`-prefixed method names are fine here.)
- **Database:** PostgreSQL. New migration class extends `ActiveRecord::Migration[8.1]`. After `bin/rails db:migrate`, commit the updated `db/schema.rb`.
- **Constants (define once, on `RepoSubscription`):** `DOC_SUBSCRIBE_MIN_ACCOUNT_AGE = 7.days`, `DOC_ACTIVITY_WINDOW = 60.days`. Reference these constants everywhere; never hardcode `7.days`/`60.days` elsewhere.
- **System/liveness writes bypass the gate:** every non-user liveness write (doc click, resume, sweep stamp) uses `update_columns`/`update_column`, NOT `update`. This is deliberate: `set_read_write` runs on every `before_save` and the entry-gate validation runs on every `save`; a plain `update` on a liveness stamp could spuriously re-fire the gate or rewrite `read`/`write`. `update_columns` skips validations and callbacks, which is correct for a pure liveness stamp.
- **Kill switch:** `ENV["DISABLE_DOC_GENERATION"]` — any truthy presence disables. `populate_docs!` returns the string `"Skipped, doc generation disabled"` (consistent with its existing `"Skipped, ..."` returns).
- **Signed id:** purpose `:resume_docs`, `expires_in: 30.days`.
- **Copy string reuse:** the 7-day block message is used verbatim in BOTH the model validation error and the UI, and asserted (as a substring) in tests:
  `You can turn on docs once your account is 7 days old, or if this repo already has active doc subscribers.`

---

## File Structure

**Migration**
- Create `db/migrate/20260916000001_add_docs_liveness_to_repo_subscriptions.rb` — adds `docs_last_click_at`, `docs_reopt_in_sent_at`; backfills existing doc subs to active.

**Models**
- Modify `app/models/repo_subscription.rb` — constants; `docs`/`active_docs`/`inactive_docs_needing_reopt_in` scopes; entry-gate validation; `docs_last_click_at` seeding callback.
- Modify `app/models/repo.rb` — redefine `query_docs_subscriber_count`; add `has_active_doc_subscribers?`, `has_doc_subscribers?`, `doc_opt_in_open_to?`; kill-switch guard in `populate_docs!`.

**Controllers**
- Modify `app/controllers/doc_methods_controller.rb` — stamp `docs_last_click_at` / clear `docs_reopt_in_sent_at` on both click actions.
- Modify `app/controllers/repo_subscriptions_controller.rb` — `resume` action; skip auth for it.

**Mailer / view / routes / task**
- Modify `app/mailers/user_mailer.rb` — `resume_docs`.
- Create `app/views/user_mailer/resume_docs.md.erb` — re-opt-in email body.
- Modify `config/routes.rb` — `resume_docs` route.
- Modify `lib/tasks/schedule.rake` — `pause_inactive_docs` task; kill-switch guard in `process_repos`.

**Views (UI wording)**
- Modify `app/views/repos/show.html.slim` — doc CTA: normal link vs. 7-day-block wording.
- Modify `app/views/repos/_docs.html.slim` — docs tab: "awaiting" vs. "paused" empty states.

**Tests**
- Create `test/unit/repo_subscription_docs_scopes_test.rb`
- Create `test/unit/repo_subscription_docs_gate_test.rb`
- Modify `test/unit/repo_test.rb`
- Modify `test/functional/doc_methods_controller_test.rb`
- Modify `test/functional/repo_subscriptions_controller_test.rb`
- Modify `test/functional/user_mailer_test.rb`
- Create `test/tasks/schedule_pause_inactive_docs_test.rb`
- Create `test/tasks/schedule_process_repos_test.rb`
- Create `test/integration/doc_gating_ui_test.rb`

---

## Task 1: Migration — add liveness columns + backfill

**Files:**
- Create: `db/migrate/20260916000001_add_docs_liveness_to_repo_subscriptions.rb`
- Modify: `db/schema.rb` (regenerated by migrate)

**Interfaces:**
- Produces: two new columns on `repo_subscriptions` — `docs_last_click_at :datetime`, `docs_reopt_in_sent_at :datetime`. Existing `read || write` subscriptions get `docs_last_click_at = NOW()` (so nothing pauses on day one).

- [ ] **Step 1: Write the migration**

```ruby
# frozen_string_literal: true

class AddDocsLivenessToRepoSubscriptions < ActiveRecord::Migration[8.1]
  def up
    add_column :repo_subscriptions, :docs_last_click_at, :datetime
    add_column :repo_subscriptions, :docs_reopt_in_sent_at, :datetime

    # Backfill: seed every existing doc subscription as active so the redefined
    # docs_subscriber_count equals the old count immediately after deploy and
    # nothing pauses on day one. Raw SQL avoids coupling to the model.
    execute(<<~SQL)
      UPDATE repo_subscriptions
      SET docs_last_click_at = NOW()
      WHERE read = true OR write = true
    SQL
  end

  def down
    remove_column :repo_subscriptions, :docs_reopt_in_sent_at
    remove_column :repo_subscriptions, :docs_last_click_at
  end
end
```

- [ ] **Step 2: Run the migration**

Run: `bin/rails db:migrate`
Expected: migration runs; `db/schema.rb` version becomes `2026_09_16_000001` and the `repo_subscriptions` table gains `docs_last_click_at` and `docs_reopt_in_sent_at`.

- [ ] **Step 3: Sync the test database**

Run: `bin/rails db:test:prepare`
Expected: no error (test schema now matches).

- [ ] **Step 4: Verify the columns exist**

Run: `bin/rails runner 'raise "missing column" unless (RepoSubscription.column_names & ["docs_last_click_at", "docs_reopt_in_sent_at"]).size == 2; puts "ok"'`
Expected: prints `ok`.

- [ ] **Step 5: Commit**

```bash
bundle exec standardrb --fix db/migrate/20260916000001_add_docs_liveness_to_repo_subscriptions.rb
git add db/migrate/20260916000001_add_docs_liveness_to_repo_subscriptions.rb db/schema.rb
git commit -m "Add docs liveness columns to repo_subscriptions"
```

---

## Task 2: RepoSubscription doc scopes + constants

**Files:**
- Modify: `app/models/repo_subscription.rb`
- Test: `test/unit/repo_subscription_docs_scopes_test.rb`

**Interfaces:**
- Consumes: `docs_last_click_at`, `docs_reopt_in_sent_at`, `read`, `write` columns (Task 1).
- Produces:
  - `RepoSubscription::DOC_SUBSCRIBE_MIN_ACCOUNT_AGE` (= `7.days`)
  - `RepoSubscription::DOC_ACTIVITY_WINDOW` (= `60.days`)
  - `RepoSubscription.docs` — subscriptions with `read = true OR write = true`
  - `RepoSubscription.active_docs` — `docs` with `docs_last_click_at > DOC_ACTIVITY_WINDOW.ago`
  - `RepoSubscription.inactive_docs_needing_reopt_in` — `docs` with stale click AND `docs_reopt_in_sent_at IS NULL`

- [ ] **Step 1: Write the failing test**

Create `test/unit/repo_subscription_docs_scopes_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RepoSubscriptionDocsScopesTest < ActiveSupport::TestCase
  # write_doc_only is the only fixture with write=true persisted; the others
  # (schneems_to_triage, read_doc_only) set only limits, which fixtures do not
  # translate into the read/write booleans, so they are NOT in the docs scope.
  test "docs scope selects only read-or-write subscriptions" do
    assert_includes RepoSubscription.docs, repo_subscriptions(:write_doc_only)
    refute_includes RepoSubscription.docs, repo_subscriptions(:schneems_to_triage)
    refute_includes RepoSubscription.docs, repo_subscriptions(:read_doc_only)
  end

  test "active_docs excludes a doc sub with a stale docs_last_click_at" do
    sub = repo_subscriptions(:write_doc_only)

    sub.update_column(:docs_last_click_at, Time.current)
    assert_includes RepoSubscription.active_docs, sub

    sub.update_column(:docs_last_click_at, (RepoSubscription::DOC_ACTIVITY_WINDOW + 1.day).ago)
    refute_includes RepoSubscription.active_docs, sub
  end

  test "inactive_docs_needing_reopt_in selects stale, un-notified doc subs only" do
    sub = repo_subscriptions(:write_doc_only)

    sub.update_columns(
      docs_last_click_at: (RepoSubscription::DOC_ACTIVITY_WINDOW + 1.day).ago,
      docs_reopt_in_sent_at: nil
    )
    assert_includes RepoSubscription.inactive_docs_needing_reopt_in, sub

    # already notified this episode -> excluded
    sub.update_column(:docs_reopt_in_sent_at, Time.current)
    refute_includes RepoSubscription.inactive_docs_needing_reopt_in, sub

    # active again -> excluded
    sub.update_columns(docs_last_click_at: Time.current, docs_reopt_in_sent_at: nil)
    refute_includes RepoSubscription.inactive_docs_needing_reopt_in, sub
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/unit/repo_subscription_docs_scopes_test.rb`
Expected: FAIL — `NoMethodError: undefined method 'docs'` (scopes not defined).

- [ ] **Step 3: Add constants and scopes**

In `app/models/repo_subscription.rb`, add the constants directly under the existing `DEFAULT_WRITE_LIMIT = 3` (line 5):

```ruby
  DOC_SUBSCRIBE_MIN_ACCOUNT_AGE = 7.days
  DOC_ACTIVITY_WINDOW = 60.days
```

Then add the scopes below the `belongs_to`/`has_many` associations (after line 16, `has_many :doc_assignments`):

```ruby
  scope :docs, -> { where(read: true).or(where(write: true)) }
  scope :active_docs, -> { docs.where("docs_last_click_at > ?", DOC_ACTIVITY_WINDOW.ago) }
  scope :inactive_docs_needing_reopt_in, lambda {
    docs.where("docs_last_click_at <= ?", DOC_ACTIVITY_WINDOW.ago)
      .where(docs_reopt_in_sent_at: nil)
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bin/rails test test/unit/repo_subscription_docs_scopes_test.rb`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
bundle exec standardrb --fix app/models/repo_subscription.rb test/unit/repo_subscription_docs_scopes_test.rb
git add app/models/repo_subscription.rb test/unit/repo_subscription_docs_scopes_test.rb
git commit -m "Add doc-liveness scopes and constants to RepoSubscription"
```

---

## Task 3: Redefine active-doc count + add Repo trust predicates

**Files:**
- Modify: `app/models/repo.rb` (redefine `query_docs_subscriber_count` at `repo.rb:259-268`; add three predicates near `can_doctor_docs?` at `repo.rb:38-40`)
- Test: `test/unit/repo_test.rb`

**Interfaces:**
- Consumes: `RepoSubscription.active_docs`, `.docs`, `DOC_SUBSCRIBE_MIN_ACCOUNT_AGE` (Task 2).
- Produces:
  - `Repo#query_docs_subscriber_count` now returns `repo_subscriptions.active_docs.count` (private; recomputed by the existing `force_issues_count_sync!`).
  - `Repo#has_active_doc_subscribers?` → Boolean
  - `Repo#has_doc_subscribers?` → Boolean
  - `Repo#doc_opt_in_open_to?(user)` → Boolean (true when repo already has an active doc sub, OR `user` is nil, OR `user.created_at <= DOC_SUBSCRIBE_MIN_ACCOUNT_AGE.ago`). Caller is responsible for checking `can_doctor_docs?` first.

- [ ] **Step 1: Write the failing test**

Append to `test/unit/repo_test.rb` (inside the existing `class RepoTest < ActiveSupport::TestCase`):

```ruby
  test "docs_subscriber_count counts only active doc subscriptions" do
    repo = repos(:no_subscribers)
    sub = RepoSubscription.create!(repo: repo, user: users(:schneems), write_limit: 1)
    sub.update_column(:docs_last_click_at, Time.current)

    repo.force_issues_count_sync!
    assert_equal 1, repo.reload.docs_subscriber_count

    sub.update_column(:docs_last_click_at, (RepoSubscription::DOC_ACTIVITY_WINDOW + 1.day).ago)
    repo.force_issues_count_sync!
    assert_equal 0, repo.reload.docs_subscriber_count
  end

  test "has_doc_subscribers? is true only when a read/write subscription exists" do
    assert repos(:issue_triage_sandbox).has_doc_subscribers? # write_doc_only
    refute repos(:no_subscribers).has_doc_subscribers?
  end

  test "has_active_doc_subscribers? requires a recent doc click" do
    repo = repos(:issue_triage_sandbox)
    refute repo.has_active_doc_subscribers? # write_doc_only has nil docs_last_click_at

    repo_subscriptions(:write_doc_only).update_column(:docs_last_click_at, Time.current)
    assert repo.has_active_doc_subscribers?
  end

  test "doc_opt_in_open_to? gates fresh accounts unless the repo is already active" do
    repo = repos(:no_subscribers)
    old_user = users(:schneems) # created 2012
    new_user = users(:mockstar)
    new_user.update_column(:created_at, Time.current)

    assert repo.doc_opt_in_open_to?(old_user)
    assert repo.doc_opt_in_open_to?(nil) # logged-out visitor sees the CTA
    refute repo.doc_opt_in_open_to?(new_user)

    active = RepoSubscription.create!(repo: repo, user: old_user, write_limit: 1)
    active.update_column(:docs_last_click_at, Time.current)
    assert repo.doc_opt_in_open_to?(new_user)
  end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/unit/repo_test.rb -n "/doc/"`
Expected: FAIL — `NoMethodError: undefined method 'has_doc_subscribers?'` (and the count test asserts on the not-yet-redefined behavior).

- [ ] **Step 3: Redefine the count and add predicates**

In `app/models/repo.rb`, replace the private `query_docs_subscriber_count` method (currently `repo.rb:259-268`) with:

```ruby
  private def query_docs_subscriber_count
    repo_subscriptions.active_docs.count
  end
```

Add these public predicates right after `can_doctor_docs?` (after `repo.rb:40`):

```ruby
  def has_active_doc_subscribers?
    repo_subscriptions.active_docs.exists?
  end

  def has_doc_subscribers?
    repo_subscriptions.docs.exists?
  end

  # Advisory check for the doc opt-in CTA. Mirrors the RepoSubscription entry
  # gate (Layer 1); the model validation remains the authoritative enforcement.
  # Callers must check can_doctor_docs? separately.
  def doc_opt_in_open_to?(user)
    return true if has_active_doc_subscribers?

    user.nil? || user.created_at <= RepoSubscription::DOC_SUBSCRIBE_MIN_ACCOUNT_AGE.ago
  end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bin/rails test test/unit/repo_test.rb -n "/doc/"`
Expected: PASS.

- [ ] **Step 5: Run the full model test files to catch regressions from the count change**

Run: `bin/rails test test/unit/repo_test.rb test/unit/repo_subscriptions_test.rb`
Expected: PASS (the redefinition is transparent to callers; `docs_subscriber_count` is not asserted elsewhere).

- [ ] **Step 6: Commit**

```bash
bundle exec standardrb --fix app/models/repo.rb test/unit/repo_test.rb
git add app/models/repo.rb test/unit/repo_test.rb
git commit -m "Redefine docs_subscriber_count as active doc subs and add trust predicates"
```

---

## Task 4: Entry-gate validation + docs_last_click_at seeding

**Files:**
- Modify: `app/models/repo_subscription.rb`
- Test: `test/unit/repo_subscription_docs_gate_test.rb`

**Interfaces:**
- Consumes: `active_docs` scope, `DOC_SUBSCRIBE_MIN_ACCOUNT_AGE` (Task 2).
- Produces:
  - A `validate :doc_subscription_allowed, if: :newly_enabling_docs?` that adds a `:base` error (the Global-Constraints copy string) when a subscription is *newly* becoming a doc sub and neither (account ≥7 days old) nor (repo has an active *other* doc sub) holds.
  - A `before_save :seed_docs_last_click_at` that sets `docs_last_click_at = Time.now` when a subscription is (or becomes) a doc sub and `docs_last_click_at` is nil.
  - "Newly becoming a doc sub" is computed from `read_limit`/`write_limit` (mirroring `set_read_write`), because at validation time the `read`/`write` booleans are not yet recomputed.

- [ ] **Step 1: Write the failing test**

Create `test/unit/repo_subscription_docs_gate_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class RepoSubscriptionDocsGateTest < ActiveSupport::TestCase
  # All fixture users are dated 2012, so we age one down to exercise the block.
  def new_account
    users(:mockstar).tap { |u| u.update_column(:created_at, Time.current) }
  end

  test "blocks a fresh account from enabling docs when no active doc subs exist" do
    sub = new_account.repo_subscriptions.new(repo: repos(:no_subscribers), write_limit: 1)

    refute sub.valid?
    assert_includes sub.errors[:base].join, "your account is 7 days old"
  end

  test "allows an account older than 7 days to enable docs" do
    sub = users(:schneems).repo_subscriptions.new(repo: repos(:no_subscribers), write_limit: 1)
    assert sub.valid?
  end

  test "allows a fresh account when the repo already has an active doc subscriber" do
    repo = repos(:no_subscribers)
    other = RepoSubscription.create!(repo: repo, user: users(:schneems), write_limit: 1)
    other.update_column(:docs_last_click_at, Time.current)

    sub = new_account.repo_subscriptions.new(repo: repo, read_limit: 1)
    assert sub.valid?
  end

  test "does not re-gate an existing doc subscription that only changes its limits" do
    repo = repos(:no_subscribers)
    sub = users(:mockstar).repo_subscriptions.create!(repo: repo, write_limit: 1) # allowed while old
    users(:mockstar).update_column(:created_at, Time.current) # now pretend brand-new

    sub.reload
    sub.assign_attributes(write_limit: 5)
    assert sub.valid?
  end

  test "does not gate disabling docs" do
    repo = repos(:no_subscribers)
    sub = users(:mockstar).repo_subscriptions.create!(repo: repo, write_limit: 1)
    users(:mockstar).update_column(:created_at, Time.current)

    sub.reload
    sub.assign_attributes(write_limit: 0)
    assert sub.valid?
  end

  test "seeds docs_last_click_at when a subscription becomes a doc subscription" do
    sub = users(:schneems).repo_subscriptions.create!(repo: repos(:no_subscribers), write_limit: 1)

    assert_not_nil sub.docs_last_click_at
    assert sub.docs_last_click_at > 1.minute.ago
  end

  test "does not seed docs_last_click_at for an issue-only subscription" do
    sub = users(:schneems).repo_subscriptions.create!(repo: repos(:no_subscribers), email_limit: 3)
    assert_nil sub.docs_last_click_at
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/unit/repo_subscription_docs_gate_test.rb`
Expected: FAIL — the block test fails (`sub.valid?` returns true; no `:base` error) and the seeding test fails (`docs_last_click_at` is nil).

- [ ] **Step 3: Add the validation, seeding callback, and helpers**

In `app/models/repo_subscription.rb`, add the validation with the other `validates` lines (after `repo_subscription.rb:9`):

```ruby
  validate :doc_subscription_allowed, if: :newly_enabling_docs?
```

Add the seeding callback immediately after the existing `before_save :set_read_write` (line 18) so it runs *after* `set_read_write` has computed `read`/`write`:

```ruby
  before_save :seed_docs_last_click_at
```

Add these methods to the class (place them near the bottom, before the final `end`):

```ruby
  def seed_docs_last_click_at
    if (read || write) && docs_last_click_at.nil?
      self.docs_last_click_at = Time.now
    end
    true
  end

  private

  # The gate fires only when a subscription is newly becoming a doc sub. We read
  # intent from the incoming limits (mirroring set_read_write) because the
  # read/write booleans are not recomputed until the before_save callback, which
  # runs after validation.
  def newly_enabling_docs?
    will_be_doc_subscription? && !was_doc_subscription?
  end

  def will_be_doc_subscription?
    doc_limit?(read_limit) || doc_limit?(write_limit)
  end

  def was_doc_subscription?
    !!read_in_database || !!write_in_database
  end

  def doc_limit?(limit)
    !(limit.blank? || limit.zero?)
  end

  def doc_subscription_allowed
    return if user && user.created_at <= DOC_SUBSCRIBE_MIN_ACCOUNT_AGE.ago
    return if repo && repo.repo_subscriptions.active_docs.where.not(id: id).exists?

    errors.add(:base, "You can turn on docs once your account is 7 days old, or if this repo already has active doc subscribers.")
  end
```

Note: `set_read_write` is currently a public method (called nowhere else externally, but keep its visibility unchanged). Add the new `private` keyword only above the gate helpers as shown, so `seed_docs_last_click_at` (called by the callback) stays callable and the gate helpers are private.

- [ ] **Step 4: Run test to verify it passes**

Run: `bin/rails test test/unit/repo_subscription_docs_gate_test.rb`
Expected: PASS (7 tests).

- [ ] **Step 5: Run related suites to confirm no regression**

Run: `bin/rails test test/unit/repo_subscriptions_test.rb test/functional/repo_subscriptions_controller_test.rb`
Expected: PASS (all fixture users are dated 2012, so existing doc subscribes still clear the gate).

- [ ] **Step 6: Commit**

```bash
bundle exec standardrb --fix app/models/repo_subscription.rb test/unit/repo_subscription_docs_gate_test.rb
git add app/models/repo_subscription.rb test/unit/repo_subscription_docs_gate_test.rb
git commit -m "Gate enabling docs behind account age or an active doc subscriber"
```

---

## Task 5: Record doc-click liveness on both click actions

**Files:**
- Modify: `app/controllers/doc_methods_controller.rb` (`click_method_redirect` success branch at `:23-27`; `click_source_redirect` success branch at `:41-45`)
- Test: `test/functional/doc_methods_controller_test.rb`

**Interfaces:**
- Consumes: `docs_last_click_at`, `docs_reopt_in_sent_at` columns (Task 1); the already-loaded `sub` local in both actions.
- Produces: each successful click sets `sub.docs_last_click_at = Time.now` and clears `sub.docs_reopt_in_sent_at`, via `update_columns` (bypassing the gate/`set_read_write`).

- [ ] **Step 1: Write the failing test**

Append to `test/functional/doc_methods_controller_test.rb` (inside the existing `class DocMethodsControllerTest`):

```ruby
  test "click_method_redirect stamps docs_last_click_at and clears reopt-in" do
    DocAssignment.create(doc_method_id: @triage_doc.id, repo_subscription_id: @repo_sub.id)
    @repo_sub.update_columns(docs_last_click_at: 90.days.ago, docs_reopt_in_sent_at: 30.days.ago)

    get :click_method_redirect, params: {id: @triage_doc.id, user_id: @user.id}

    @repo_sub.reload
    assert @repo_sub.docs_last_click_at > 1.minute.ago
    assert_nil @repo_sub.docs_reopt_in_sent_at
  end

  test "click_source_redirect stamps docs_last_click_at and clears reopt-in" do
    DocAssignment.create(doc_method_id: @triage_doc.id, repo_subscription_id: @repo_sub.id)
    @repo_sub.update_columns(docs_last_click_at: 90.days.ago, docs_reopt_in_sent_at: 30.days.ago)

    get :click_source_redirect, params: {id: @triage_doc.id, user_id: @user.id}

    @repo_sub.reload
    assert @repo_sub.docs_last_click_at > 1.minute.ago
    assert_nil @repo_sub.docs_reopt_in_sent_at
  end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/functional/doc_methods_controller_test.rb -n "/stamps/"`
Expected: FAIL — `docs_last_click_at` is still `90.days.ago` (not updated).

- [ ] **Step 3: Add the liveness stamp to both actions**

In `app/controllers/doc_methods_controller.rb`, inside `click_method_redirect`, add the stamp right after `assignment.user.update(last_clicked_at: Time.now)` (line 26):

```ruby
      sub.update_columns(docs_last_click_at: Time.now, docs_reopt_in_sent_at: nil)
```

Do the same inside `click_source_redirect`, right after `assignment.user.update(last_clicked_at: Time.now)` (line 44):

```ruby
      sub.update_columns(docs_last_click_at: Time.now, docs_reopt_in_sent_at: nil)
```

(In both actions `sub` is already loaded and non-nil on the success branch.)

- [ ] **Step 4: Run test to verify it passes**

Run: `bin/rails test test/functional/doc_methods_controller_test.rb`
Expected: PASS (existing 2 tests + new 2).

- [ ] **Step 5: Commit**

```bash
bundle exec standardrb --fix app/controllers/doc_methods_controller.rb test/functional/doc_methods_controller_test.rb
git add app/controllers/doc_methods_controller.rb test/functional/doc_methods_controller_test.rb
git commit -m "Record per-subscription doc-click liveness on click redirects"
```

---

## Task 6: Re-opt-in route + resume action

**Files:**
- Modify: `config/routes.rb` (after `:50`)
- Modify: `app/controllers/repo_subscriptions_controller.rb` (`:4` before_action; add `resume`)
- Test: `test/functional/repo_subscriptions_controller_test.rb`

**Interfaces:**
- Consumes: `docs_last_click_at`, `docs_reopt_in_sent_at` (Task 1).
- Produces:
  - Route `resume_docs` → `get "/repo_subscriptions/:signed_id/resume"`; URL helper `resume_docs_url(signed_id)` (used by Task 7's email).
  - `RepoSubscriptionsController#resume` — resolves `RepoSubscription.find_signed(params[:signed_id], purpose: :resume_docs)`; on success reactivates via `update_columns(docs_last_click_at: Time.now, docs_reopt_in_sent_at: nil)` and redirects to the repo; on nil, flashes an error and redirects to root. `authenticate_user!` is skipped for this action.

- [ ] **Step 1: Write the failing test**

Append to `test/functional/repo_subscriptions_controller_test.rb` (inside the existing `class RepoSubscriptionsControllerTest`):

```ruby
  test "resume reactivates a doc subscription from a valid signed id" do
    sub = repo_subscriptions(:write_doc_only)
    sub.update_columns(docs_last_click_at: 90.days.ago, docs_reopt_in_sent_at: 30.days.ago)

    get :resume, params: {signed_id: sub.signed_id(purpose: :resume_docs)}

    sub.reload
    assert sub.docs_last_click_at > 1.minute.ago
    assert_nil sub.docs_reopt_in_sent_at
    assert_redirected_to repo_path(sub.repo)
  end

  test "resume with an invalid signed id redirects to root with an error" do
    get :resume, params: {signed_id: "not-a-valid-signed-id"}

    assert_equal "That re-enable link is invalid or has expired.", flash[:error]
    assert_redirected_to :root
  end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/functional/repo_subscriptions_controller_test.rb -n "/resume/"`
Expected: FAIL — `No route matches {:action=>"resume"...}` / `AbstractController::ActionNotFound`.

- [ ] **Step 3: Add the route**

In `config/routes.rb`, add directly after the `resources :repo_subscriptions, only: [:create, :destroy, :update]` line (`:50`):

```ruby
  get "/repo_subscriptions/:signed_id/resume", to: "repo_subscriptions#resume", as: :resume_docs
```

- [ ] **Step 4: Add the action and skip auth for it**

In `app/controllers/repo_subscriptions_controller.rb`, change line 4 from:

```ruby
  before_action :authenticate_user!
```

to:

```ruby
  before_action :authenticate_user!, except: :resume
```

Add the `resume` action (place it after `update`, before `create_or_update_subscription`):

```ruby
  def resume
    repo_sub = RepoSubscription.find_signed(params[:signed_id], purpose: :resume_docs)
    if repo_sub
      repo_sub.update_columns(docs_last_click_at: Time.now, docs_reopt_in_sent_at: nil)
      redirect_to repo_sub.repo, notice: "Docs re-enabled — you'll start receiving them again soon."
    else
      flash[:error] = "That re-enable link is invalid or has expired."
      redirect_to :root
    end
  end
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bin/rails test test/functional/repo_subscriptions_controller_test.rb`
Expected: PASS (existing tests + new 2).

- [ ] **Step 6: Commit**

```bash
bundle exec standardrb --fix config/routes.rb app/controllers/repo_subscriptions_controller.rb test/functional/repo_subscriptions_controller_test.rb
git add config/routes.rb app/controllers/repo_subscriptions_controller.rb test/functional/repo_subscriptions_controller_test.rb
git commit -m "Add signed-id resume action to re-enable paused doc subscriptions"
```

---

## Task 7: resume_docs mailer + template

**Files:**
- Modify: `app/mailers/user_mailer.rb` (after `daily_docs`, `:68`)
- Create: `app/views/user_mailer/resume_docs.md.erb`
- Test: `test/functional/user_mailer_test.rb`

**Interfaces:**
- Consumes: `resume_docs_url` route helper (Task 6); `RepoSubscription#signed_id` (built-in).
- Produces: `UserMailer#resume_docs(repo_subscription:)` — sets `@repo_subscription`, `@repo`, `@user`; returns early (nil) if the user has no email (via `set_and_check_user`); otherwise renders `resume_docs.md.erb` with a signed-id resume link.

- [ ] **Step 1: Write the failing test**

Append to `test/functional/user_mailer_test.rb` (inside the existing `class UserMailerTest`):

```ruby
  test "resume_docs renders and links to the repo" do
    repo_sub = repo_subscriptions(:write_doc_only)
    email = UserMailer.resume_docs(repo_subscription: repo_sub)

    assert_emails 1 do
      email.deliver_now
    end
    assert_match repo_sub.repo.full_name, email.body.to_s
    assert_match "/resume", email.body.to_s
  end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/functional/user_mailer_test.rb -n "/resume_docs/"`
Expected: FAIL — `NoMethodError: undefined method 'resume_docs'`.

- [ ] **Step 3: Add the mailer method**

In `app/mailers/user_mailer.rb`, add after the `daily_docs` method (after `:68`):

```ruby
  def resume_docs(repo_subscription:)
    @repo_subscription = repo_subscription
    @repo = repo_subscription.repo
    return unless set_and_check_user(repo_subscription.user)

    mail(
      to: @user.email,
      reply_to: "noreply@codetriage.com",
      subject: "Want to keep getting docs for #{@repo.full_name}?"
    )
  end
```

- [ ] **Step 4: Create the template**

Create `app/views/user_mailer/resume_docs.md.erb`:

```erb
Hi @<%= @user.github %>,

It's been a while since you engaged with docs for **<%= @repo.full_name %>**, so we've paused doc suggestions for you.

Want to keep helping? Re-enable them with one click:

[Re-enable docs for <%= @repo.full_name %>](<%= resume_docs_url(@repo_subscription.signed_id(purpose: :resume_docs, expires_in: 30.days)) %>)

--

Go forth and make the world a better place

[Help doctor more docs at codetriage.com](<%= root_url %>)
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bin/rails test test/functional/user_mailer_test.rb`
Expected: PASS (existing 2 + new 1).

- [ ] **Step 6: Commit**

```bash
bundle exec standardrb --fix app/mailers/user_mailer.rb test/functional/user_mailer_test.rb
git add app/mailers/user_mailer.rb app/views/user_mailer/resume_docs.md.erb test/functional/user_mailer_test.rb
git commit -m "Add resume_docs re-opt-in mailer"
```

---

## Task 8: Daily inactivity sweep task

**Files:**
- Modify: `lib/tasks/schedule.rake` (add task near the other `schedule:*` tasks)
- Test: `test/tasks/schedule_pause_inactive_docs_test.rb`

**Interfaces:**
- Consumes: `RepoSubscription.inactive_docs_needing_reopt_in` (Task 2); `UserMailer#resume_docs` (Task 7); `ENV["DISABLE_DOC_GENERATION"]` (kill switch).
- Produces: `rake schedule:pause_inactive_docs` — for each inactive, un-notified doc subscription, enqueues `UserMailer.resume_docs(...).deliver_later` and stamps `docs_reopt_in_sent_at = Time.now` (once per inactivity episode). No-op when the kill switch is set.

- [ ] **Step 1: Write the failing test**

Create `test/tasks/schedule_pause_inactive_docs_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"
require "rake"

class SchedulePauseInactiveDocsTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake::Task.define_task(:environment)
    @rake.rake_require("schedule", ["#{Rails.root}/lib/tasks"], [])
  end

  test "emails inactive doc subscribers a re-opt-in and stamps them" do
    stale = repo_subscriptions(:write_doc_only)
    stale.update_columns(
      docs_last_click_at: (RepoSubscription::DOC_ACTIVITY_WINDOW + 1.day).ago,
      docs_reopt_in_sent_at: nil
    )

    assert_enqueued_emails 1 do
      @rake["schedule:pause_inactive_docs"].invoke
    end

    assert_not_nil stale.reload.docs_reopt_in_sent_at
  end

  test "does not email active doc subscribers" do
    active = repo_subscriptions(:write_doc_only)
    active.update_columns(docs_last_click_at: Time.current, docs_reopt_in_sent_at: nil)

    assert_no_enqueued_emails do
      @rake["schedule:pause_inactive_docs"].invoke
    end
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/tasks/schedule_pause_inactive_docs_test.rb`
Expected: FAIL — `Don't know how to build task 'schedule:pause_inactive_docs'`.

- [ ] **Step 3: Add the task**

In `lib/tasks/schedule.rake`, add inside the `namespace :schedule do` block (e.g. after the `mark_closed` task, `:52`):

```ruby
  desc "Pause inactive doc subscriptions and email a one-click re-opt-in"
  task pause_inactive_docs: :environment do
    next if ENV["DISABLE_DOC_GENERATION"]

    RepoSubscription.inactive_docs_needing_reopt_in.find_each(batch_size: 1000) do |sub|
      UserMailer.resume_docs(repo_subscription: sub).deliver_later
      sub.update_column(:docs_reopt_in_sent_at, Time.now)
    end
  end
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bin/rails test test/tasks/schedule_pause_inactive_docs_test.rb`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
bundle exec standardrb --fix lib/tasks/schedule.rake test/tasks/schedule_pause_inactive_docs_test.rb
git add lib/tasks/schedule.rake test/tasks/schedule_pause_inactive_docs_test.rb
git commit -m "Add daily sweep that emails a re-opt-in link to inactive doc subs"
```

---

## Task 9: Global kill switch

**Files:**
- Modify: `app/models/repo.rb` (`populate_docs!`, first body line after `:65`)
- Modify: `lib/tasks/schedule.rake` (`process_repos`, `:15-19`)
- Test: `test/unit/repo_test.rb`; `test/tasks/schedule_process_repos_test.rb`

**Interfaces:**
- Consumes: `ENV["DISABLE_DOC_GENERATION"]`.
- Produces:
  - `Repo#populate_docs!` returns `"Skipped, doc generation disabled"` (before any clone/parse) when the kill switch is set.
  - `schedule:process_repos` enqueues no `PopulateDocsJob` when the kill switch is set.

- [ ] **Step 1: Write the failing tests**

Append to `test/unit/repo_test.rb` (inside `class RepoTest`):

```ruby
  test "populate_docs! short-circuits when doc generation is disabled" do
    ENV["DISABLE_DOC_GENERATION"] = "1"
    repo = repos(:issue_triage_sandbox)

    # Pass commit_sha so the default-arg fetcher (network) is never evaluated;
    # the kill-switch guard is the first line of the method body.
    assert_equal "Skipped, doc generation disabled", repo.populate_docs!(commit_sha: "abc123")
  ensure
    ENV.delete("DISABLE_DOC_GENERATION")
  end
```

Create `test/tasks/schedule_process_repos_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"
require "rake"

class ScheduleProcessReposTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake::Task.define_task(:environment)
    @rake.rake_require("schedule", ["#{Rails.root}/lib/tasks"], [])
  end

  test "enqueues a PopulateDocsJob for active repos with active doc subs" do
    repos(:issue_triage_sandbox).update_column(:docs_subscriber_count, 1)

    assert_enqueued_jobs(1, only: PopulateDocsJob) do
      @rake["schedule:process_repos"].invoke
    end
  end

  test "enqueues nothing when doc generation is disabled" do
    repos(:issue_triage_sandbox).update_column(:docs_subscriber_count, 1)
    ENV["DISABLE_DOC_GENERATION"] = "1"

    assert_no_enqueued_jobs(only: PopulateDocsJob) do
      @rake["schedule:process_repos"].invoke
    end
  ensure
    ENV.delete("DISABLE_DOC_GENERATION")
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bin/rails test test/unit/repo_test.rb -n "/kill|disabled/" test/tasks/schedule_process_repos_test.rb`
Expected: FAIL — `populate_docs!` does not return the disabled string; `process_repos` enqueues a job even with the ENV set.

- [ ] **Step 3: Guard `populate_docs!`**

In `app/models/repo.rb`, add as the first line of the `populate_docs!` body (immediately after the `def populate_docs!(...)` signature at `:65`, before `return "Skipped, lang not supported" ...`):

```ruby
    return "Skipped, doc generation disabled" if ENV["DISABLE_DOC_GENERATION"]
```

- [ ] **Step 4: Guard `process_repos`**

In `lib/tasks/schedule.rake`, add as the first line inside the `task process_repos: :environment do` block (before the `Repo.active...` line at `:16`):

```ruby
    next if ENV["DISABLE_DOC_GENERATION"]
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `bin/rails test test/unit/repo_test.rb test/tasks/schedule_process_repos_test.rb`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
bundle exec standardrb --fix app/models/repo.rb lib/tasks/schedule.rake test/unit/repo_test.rb test/tasks/schedule_process_repos_test.rb
git add app/models/repo.rb lib/tasks/schedule.rake test/unit/repo_test.rb test/tasks/schedule_process_repos_test.rb
git commit -m "Add DISABLE_DOC_GENERATION kill switch to job and scheduler"
```

---

## Task 10: UI wording — CTA gate + docs-tab empty states

**Files:**
- Modify: `app/views/repos/show.html.slim` (doc CTA at `:47-50`)
- Modify: `app/views/repos/_docs.html.slim` (`:3-4`)
- Test: `test/integration/doc_gating_ui_test.rb`

**Interfaces:**
- Consumes: `Repo#doc_opt_in_open_to?`, `#has_doc_subscribers?` (Task 3); `Repo#can_doctor_docs?`, `#docs_subscriber_count` (existing).
- Produces: three user-facing states — "Triage Docs" link (open), 7-day block wording (locked), "awaiting a qualified subscriber" (no doc subs), and "paused" (doc subs exist, none active).

- [ ] **Step 1: Write the failing test**

Create `test/integration/doc_gating_ui_test.rb`:

```ruby
# frozen_string_literal: true

require "test_helper"

class DocGatingUiTest < ActionDispatch::IntegrationTest
  test "awaiting message shows for a Ruby repo with no doc subscribers" do
    visit repo_path(repos(:no_subscribers))
    assert_text "Doc suggestions turn on once this repo has an established subscriber"
  end

  test "paused message shows when doc subscribers exist but none are active" do
    # write_doc_only is a doc sub on issue_triage_sandbox with a nil docs_last_click_at.
    visit repo_path(repos(:issue_triage_sandbox))
    assert_text "Doc suggestions are paused"
  end

  test "a fresh account is told it cannot enable docs yet" do
    login_via_github # signs in mockstar
    users(:mockstar).update_column(:created_at, Time.current)

    visit repo_path(repos(:no_subscribers))
    assert_text "You can turn on docs once your account is 7 days old"
  end
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bin/rails test test/integration/doc_gating_ui_test.rb`
Expected: FAIL — none of the new copy is present yet.

- [ ] **Step 3: Update the doc CTA in show.html.slim**

In `app/views/repos/show.html.slim`, replace the `can_doctor_docs?` branch of the doc CTA (currently `:47-50`):

```slim
        - if @repo.can_doctor_docs?
          = link_to_or_log_in(text: "Triage Docs", path: repo_subscriptions_path(id: @repo_sub.try(:id), repo_subscription: { repo_id: @repo.id, read: true, write: true,  read_limit: 3, write_limit: 3, email_limit: @repo_sub.try(:email_limit) || 0 }), html_class: "repo-action")
        - else
          = link_to "#{@repo.language} not yet supported", '#', class: "button inactive repo-action"
```

with:

```slim
        - if @repo.can_doctor_docs?
          - if @repo.doc_opt_in_open_to?(current_user)
            = link_to_or_log_in(text: "Triage Docs", path: repo_subscriptions_path(id: @repo_sub.try(:id), repo_subscription: { repo_id: @repo.id, read: true, write: true,  read_limit: 3, write_limit: 3, email_limit: @repo_sub.try(:email_limit) || 0 }), html_class: "repo-action")
          - else
            p.repo-instructions You can turn on docs once your account is 7 days old, or if this repo already has active doc subscribers.
            = link_to "Docs locked", '#', class: "button inactive repo-action"
        - else
          = link_to "#{@repo.language} not yet supported", '#', class: "button inactive repo-action"
```

- [ ] **Step 4: Update the docs-tab empty state in _docs.html.slim**

In `app/views/repos/_docs.html.slim`, replace lines `:3-4`:

```slim
- if @repo.docs_subscriber_count.zero? && @repo.can_doctor_docs?
  li.slats-item Subscribe to help with docs for this repo and come back later
```

with:

```slim
- if @repo.docs_subscriber_count.zero? && @repo.can_doctor_docs?
  - if @repo.has_doc_subscribers?
    li.slats-item Doc suggestions are paused because no one's engaged recently. Click a doc, or use the re-enable link we emailed you.
  - else
    li.slats-item Doc suggestions turn on once this repo has an established subscriber.
```

- [ ] **Step 5: Run test to verify it passes**

Run: `bin/rails test test/integration/doc_gating_ui_test.rb`
Expected: PASS (3 tests).

- [ ] **Step 6: Commit**

```bash
bundle exec standardrb --fix test/integration/doc_gating_ui_test.rb
git add app/views/repos/show.html.slim app/views/repos/_docs.html.slim test/integration/doc_gating_ui_test.rb
git commit -m "Surface doc trust-gate states in the repo UI"
```

---

## Task 11: Full-suite + lint verification

**Files:** none (verification only).

- [ ] **Step 1: Run the full test suite (matches CI)**

Run: `bin/rake test`
Expected: PASS, no failures or errors.

- [ ] **Step 2: Run the linter (matches CI)**

Run: `bundle exec standardrb`
Expected: no offenses.

- [ ] **Step 3: Confirm the seed task still boots (matches CI)**

Run: `RAILS_ENV=test bin/rails db:seed`
Expected: completes without error.

- [ ] **Step 4: If anything failed, fix and re-run before finishing.**

---

## Deployment notes (out of band — not code)

These are operational follow-ups after merge, captured here so they aren't lost:

1. Add a Heroku Scheduler entry for `rake schedule:pause_inactive_docs` (daily), alongside the existing `schedule:*` entries. Without this, subscriptions never get the re-opt-in email (generation still winds down correctly via `mark_closed` recomputing the count).
2. The kill switch is flipped with `heroku config:set DISABLE_DOC_GENERATION=1` (and unset to re-enable). It restarts dynos — acceptable for incident response.

## Self-Review

**Spec coverage** (each spec section → task):
- Feature 1, Layer 1 (hard subscribe-time block) → Task 4 (validation).
- Feature 1, Layer 2 (derived active-doc count) → Task 3 (`query_docs_subscriber_count` redefinition). `process_repos`/`populate_docs!` need no change for Layer 2 — confirmed, they read `docs_subscriber_count` which is transparently redefined.
- Feature 2 columns → Task 1. Liveness tracking (clicks) → Task 5. Seeding grace → Task 4. Sweep + re-opt-in email → Tasks 6 (route/action), 7 (mailer), 8 (task). "Pause is emergent" — no flag added; correct.
- Feature 3 kill switch (both `process_repos` and `populate_docs!`) → Task 9.
- UI wording (all three states) → Task 10.
- Data-model table (2 columns + backfill + redefine + no repo columns) → Tasks 1, 3.
- Constants → Task 2. Testing matrix → distributed across Tasks 2–10. Rollout day-one-no-pause (backfill = now) → Task 1.
- Open questions: MVP gates generation only (not sending) — honored (no send-path change). Resume link is unauthenticated signed id — Task 6 (`except: :resume`).

**Placeholder scan:** No TBD/TODO; every step has runnable code or an exact command. The email/UI copy is the spec's placeholder wording — intentionally shipped as-is per the spec ("placeholder for Schneems to finalize"); it is not a plan gap.

**Type/name consistency:** `DOC_SUBSCRIBE_MIN_ACCOUNT_AGE` and `DOC_ACTIVITY_WINDOW` are defined once (Task 2) and referenced by name in Tasks 3, 4, and tests. Scope names `docs`/`active_docs`/`inactive_docs_needing_reopt_in` are used consistently. Predicate names `has_active_doc_subscribers?`/`has_doc_subscribers?`/`doc_opt_in_open_to?` match between Task 3 (definition), Task 10 (view usage), and tests. The block copy string is identical in the validation (Task 4), the view (Task 10), and the assertions. `update_columns` (not `update`) is used for every liveness write (Tasks 5, 6, 8). The kill-switch string `"Skipped, doc generation disabled"` matches between `populate_docs!` (Task 9) and its test. Signed-id purpose `:resume_docs` matches between the mailer link (Task 7), the controller (Task 6), and the tests.
