## CodeTriage

[![Main](https://github.com/codetriage/CodeTriage/actions/workflows/main.yml/badge.svg)](https://github.com/codetriage/CodeTriage/actions/workflows/main.yml)
[![View performance data on Skylight](https://badges.skylight.io/status/IfSk4kDAh56r.svg)](https://oss.skylight.io/app/applications/IfSk4kDAh56r)
[![Code Helpers Badge](https://www.codetriage.com/codetriage/codetriage/badges/users.svg)](https://codetriage.com/codetriage/codetriage)

## What is Triage?

When patients come into the emergency room, they don't see a doctor immediately, they go to a triage nurse. The nurse knows enough about medical problems to properly assign that person to the doctor that can help them the quickest. Since the doctors are the most limited resource, triage nurses help to assign them as effectively as possible. Triage in open source means looking at open issues and adding useful information for maintainers. While you might not maintain a repository, you can help those who do by diagnosing issues, reviewing pull requests.


## Why Triage?

Triage is an important part of open source. It can be difficult to keep up with bugs and assess the validity of contributions. Code introduced to fix one problem can easily generate more problems than it solves, so it's important for maintainers to look closely at bug reports and code contributions. Unfortunately as the size of a project grows, the demands placed on the maintainers grow. This means they are forced to choose between spending enormous amounts of time reviewing each GitHub issue, only skimming over issues, or worse, ignoring issues.

As a non-maintainer, you can help an open source project by triaging issues. When issues come in, they are assigned out to triage. If you get assigned an issue, you should look closely at it, and provide feedback to make a maintainer's life easier. If there is a bug reported, try to reproduce it and then give the results in the issue comments. If code is included in the issue, review the code, see if it makes sense. Code submitted should have a clear use case, be in the same style as the project, and not introduce failures into the test system. If the code is good, leave a comment explaining why you believe it is good. +1's are great, but leave no context and don't help maintainers much. If you don't like an issue you need to explain why as well. Either way leave a comment with the issue.

## How Does it Work?

You sign up to follow a repository, once a day you'll be emailed with an open issue from that repository, and instructions on how to triage the issue in a helpful way. In the background we use Sidekiq to grab issues from GitHub's API, we then use another background task to assign users who subscribe to a repository one issue each day.

See [CONTRIBUTING.md](CONTRIBUTING.md) for details about contributing and running the project locally.


## Contact

[Richard Schneeman](https://twitter.com/schneems)

Licensed under MIT License.
Copyright (c) 2012 Schneems.
See LICENSE.txt for further details.
