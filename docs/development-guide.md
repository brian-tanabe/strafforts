# Strafforts - Development Guide

Built on [Ruby on Rails 5][Ruby on Rails] framework,
[Strafforts][Strafforts] uses [PostgreSQL][PostgreSQL] as the database engine and [AdminLTE][AdminLTE] as front-end UI template.
Therefore Strafforts can be easily deployed and run on [Heroku][Heroku]
with a free plan or setup on any local machines which are Ruby on Rails ready.

## Create Strava API application

First off, create your own Strava API application.
Any registered Strava user can obtain `Client ID` and `Client Secret`
by first creating an application at <https://www.strava.com/settings/api>,
which allows your Strafforts instance (either in the cloud or local) to connect with Strava
and retrieve data via [Strava API service][Strava API].

## Development

### Prerequisites

To get started developing Strafforts locally,
please first make sure [Ruby on Rails][Ruby on Rails]
and [PostgreSQL][PostgreSQL] environment have been properly setup on your machine.

Note that Ruby on Rails uses [Sqlite][Sqlite] by default, which also works fine with Strafforts,
but configurations in `config/database.yml` and `Gemfile` need to be updated accordingly in that case.

### Instructions

1. Clone and config repository

       git clone https://github.com/yizeng/strafforts.git

1. Install required gems

       gem install bundler foreman

1. Bundle install

       cd strafforts
       bundle

1. Generate secret tokens and create `secrets.yml`

    Use the command below to generate to two secret tokens, one for development and one for test:

       bin/rails secret

    Create a file called `config/secrets.yml` file like the following:

       # Be sure to restart your server when you modify this file.

       # Your secret key is used for verifying the integrity of signed cookies.
       # If you change this key, all old signed cookies will become invalid!

       # Make sure the secret is at least 30 characters and all random,
       # no regular words or you'll be exposed to dictionary attacks.
       # You can use `rails secret` to generate a secure secret key.

       # Make sure the secrets in this file are kept private
       # if you're sharing your code publicly.

       development:
         secret_key_base: REPLACE_WITH_YOUR_TOKEN

       test:
         secret_key_base: REPLACE_WITH_YOUR_TOKEN

       # Do not keep production secrets in the repository,
       # instead read values from the environment.
       production:
         secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>

1. Setup environment variables

    Create a file called `.env` under root directory.

    Then add the following configurations items in:

       STRAVA_API_CLIENT_ID=replace_with_client_id_of_your_strava_api_application
       STRAVA_API_CLIENT_SECRET=replace_with_client_secret_of_your_strava_api_application

    In addition, there are few more ENV variables you can set: `GOOGLE_TAG_MANAGER_TRACKER`,
    `MAILER_LITE_API_KEY`, `MAILER_LITE_GROUP_ID`.

1. Create, migrate and seed database

       bundle exec rails db:create && bundle exec rails db:migrate && bundle exec rails db:seed

1. Install JS dependencies

    The app uses [Yarn][Yarn] to manage JS dependencies. Please first make sure it's properly installed. Then use the following command to install:

       yarn

    The app uses [TypeScript][TypeScript] instead of JavaScripts. A post-install step has been configured to compile TypeScript files after `yarn`.

1. Fire up web server, worker and watcher.

       yarn start

      This command is designed to provide that one command for all development needs using [Foreman][Foreman]:
      - fire up a Rails web server

        It can be accessed from <http://localhost:5000> by default.
      - start a worker process to fetch data
      - start a webpacker process that compiles assets using [Webpack][Webpack] dev server and watch for changes.

1. Connect with Strava

      From <http://localhost:5000>, connect with your Strava account.
      If it succeeds, it should redirect to the athlete overview page.

1. Fetch data manually if needed

    Foreman's worker process should fetch all best efforts once Strafforts has connected to Strava. Alternatively, the same can be achieved by the following rake tasks defined in `/lib/tasks/fetch.rake` and `/lib/tasks/athlete.rake`.

1. Run tests

      There are few but not a lot of tests written. If you wish to run them, please follow the steps below:

      - Make sure testing DB has been created

            RAILS_ENV=test bundle exec bin/rails db:create

      - Run unit tests.

            bundle exec bin/rails test

      - Run Rails system tests.

            bundle exec bin/rails test:system

      - Alternatively, use `yarn test:all` to run both sets of tests.

## Install on Heroku

1. Clone repository

       git clone https://github.com/yizeng/strafforts.git

1. Create Heroku App

    General instructions can be followed as described in [Getting Started on Heroku with Ruby](https://devcenter.heroku.com/articles/getting-started-with-ruby#introduction).

       cd strafforts
       heroku create
       git push heroku master

       heroku config:set STRAVA_API_CLIENT_ID=`Paste in your Client ID from Strava API application page`
       heroku config:set STRAVA_API_CLIENT_SECRET=`Paste in your Client Secret from Strava API application page`

       heroku run rake db:migrate
       heroku run rake db:seed
       heroku restart

       heroku addons:create scheduler
       heroku addons:open scheduler

1. Setup Heroku Scheduler

    In Heroku's Add-ons page, setup the scheduler with `bundle exec bin/rails fetch:latest` command
    to tell it to fetch the latest data from Strava API periodically.
    Note that Strava API application has a rate limit of 600 requests every 15 minutes, 30000 daily,
    please set the scheduler to run on a reasonable interval.

1. Update Strava API Authorization Callback Domain

    Go back to [Strava API settings page][Strava API settings page]
    and update 'Authorization Callback Domain' field to be the domain of your Strafforts instance.
    For example, if you Heorku app is called `boiling-island-12345`' by default,
    the callback domain should be `boiling-island-12345.herokuapp.com`.
    If you have your own domain setup on Heroku, paste your own domain in.

1. Play around!

[Strava API]: https://developers.strava.com/docs/reference/
[Strava API settings page]: https://www.strava.com/settings/api
[estimated best efforts]: https://support.strava.com/hc/en-us/articles/216917127-Estimated-Best-Efforts-for-Running
[Strafforts]: https://www.strafforts.com
[strava-best-efforts]: https://github.com/yizeng/strava-best-efforts
[yizeng.me]: https://yizeng.me
[License]: https://raw.github.com/yizeng/strafforts/master/LICENSE
[Ruby on Rails]: http://rubyonrails.org/
[PostgreSQL]: https://www.postgresql.org/
[AdminLTE]: https://github.com/almasaeed2010/AdminLTE
[Sqlite]: https://sqlite.org/
[Heroku]: https://www.heroku.com/
[Foreman]: https://github.com/ddollar/foreman
[Yarn]: https://yarnpkg.com/en/
[TypeScript]: https://www.typescriptlang.org/
[Webpack]: https://webpack.js.org/
