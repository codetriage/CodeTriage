
## Code Triage

[![Build Status](https://secure.travis-ci.org/codetriage/codetriage.png)](http://travis-ci.org/codetriage/codetriage)

## What is Triage?

When patients come into the emergency room, they don't see a doctor immediately, they go to a triage nurse. The nurse knows enough about medical problems to properly assign that person to the doctor that can help them the quickest. Since the doctors are the most limited resource, triage nurses help to assign them as effectively as possible. Triage in open source means looking at open issues and adding useful information for maintainers. While you might not maintain a repository, you can help those who do by diagnosing issues, reviewing pull requests.


## Why Triage?

Triage is an important part of open source. It can be difficult to keep up with bugs and assess the validity of contributions. Code introduced to fix one problem can easily generate more problems than it solves, so it's important to maintainers look closely at bug reports and code contributions. Unfortunately as the size of a project grows, the demands placed on the maintainers grow. This means that maintainers are forced to choose between spending enormous amounts of time reviewing each GitHub issue, only skimming over issues, or worse ignoring issues. As a non-maintainer, you can help an open source project by triaging issues. When issues come in, they are assigned out to triage. If you get assigned an issue, you should look closely at it, and provide feedback to make a maintainers life easier. If there is a bug reported, try to reproduce it and then give the results in the issue comments. If code is included in the issue, review the code, see if it makes sense. Code submitted should have a clear use case, be in the same style as the project, and not introduce failures into the test system. If the code is good, leave a comment explaining why you believe it is good. +1's are great, but leave no context and don't help maintainers much. If you don't like an issue you need to explain why as well. Either way leave a comment with the issue.

## How does it Work?

You sign up to follow a repository, once a day you'll be emailed with an open issue from that repository, and instructions on how to triage the issue in a helpful way. In the background we use Resque to grab issues from Github's API, we then use another background task to assign users who subscribe to a repository one issue each day.


## Run Code Triage

### Dependencies
Make sure you have bundler, then install the dependencies:

```shell
  $ gem install bundler
  $ bundle install
```

### Database
Create a database (default is PostgreSQL) and run your migrations

```shell
  $ bundle exec rake db:create
  $ bundle exec rake db:migrate
````

### Install Redis

Code Triage requires Redis for background processing.

**Homebrew**

If you're on OS X, Homebrew is the simplest way to install Redis:

```shell
$ brew install redis
$ redis-server
```

You now have Redis running on 6379.

**Other**

See the Download page on Redis.io for steps to install on other systems: [http://redis.io/download](http://redis.io/download)

### Environment
If you want your users to sign up with Github, create a [GitHub Client Application](https://github.com/settings/applications), then add the credentials to your .env file:

```shell
  $ echo GITHUB_APP_ID=foo >> .env
  $ echo GITHUB_APP_SECRET=bar >> .env
```

### Running the app
Start your app using Foreman

``` shell
  $ foreman start
  08:19:22 web.1    | started with pid 6347
  08:19:22 worker.1 | started with pid 6348
```

Code Triage should now be running at [http://localhost:5000](http://localhost:5000)


## Tests

```shell
$ psql
> CREATE ROLE postgres WITH SUPERUSER CREATEDB;
> \q
```

```shell
$ rake db:create RAILS_ENV=test
$ rake db:migrate RAILS_ENV=test
```

## Flow

- A user subscribes to a repo
- Consume API: Once a day, find all the repos that haven't been updated in 24 hours, produce issue subscription
- Issue Assigning [repo]: Find all users subscribed to that repo that haven't been assigned an issue in 24 hours, pick a random issue that the user is not a part of and send them an email.


## Contact

Richard Schneeman [@Schneems](http://twitter.com/schneems) for [Heroku](http://heroku.com).

Licensed under MIT License.
Copyright (c) 2012 Schneems.
See LICENSE.txt for further details.
