Tenejo: a General Purpose Digital Repository
============================================

Tenejo gives you the most commonly used Samvera features and functions in an easy to use hosted solution.

[![CircleCI](https://circleci.com/gh/curationexperts/tenejo.svg?style=svg)](https://circleci.com/gh/curationexperts/tenejo) [![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE) [![Maintainability](https://api.codeclimate.com/v1/badges/11b857b0d512575d91c5/maintainability)](https://codeclimate.com/github/curationexperts/tenejo/maintainability)

Development
-----------

### Prerequisites
1. Ensure you have the prerequisites from https://github.com/samvera/hyrax, although you do not need a separately running Solr or Fedora instance in order to begin in development, since these are packaged with this application, in the form of solr_wrapper and fcrepo_wrapper.

### Installing
1. `git clone https://github.com/curationexperts/tenejo.git`
1. `cd ./tenejo` then check out a working branch `git checkout -b my_working_branch`
1. Copy `.env.sample` to `.env.development` if you want to override any default settings in your local development environment.
1. Setup your database.
   We use PostgreSQL. To support the test and development environments, you'll
   need have Postgres installed and running.

1. Set up your gemset using rvm (it's possible you'll need to download a new Ruby, depending on the project - `rvm install [ruby-version]`)
    ```
    rvm list rubies
    * ruby-2.5.1 [ x86_64 ]
    => ruby-2.6.3 [ x86_64 ]

    # => - current
    # =* - current && default
    #  * - default

    rvm use gemset ruby-2.6.3@tenejo --create
    ruby-2.6.3 - #gemset created /Users/max/.rvm/gems/ruby-2.6.3@tenejo
    ruby-2.6.3 - #generating tenejo wrappers.........
    Using /Users/max/.rvm/gems/ruby-2.6.3 with gemset tenejo
    ```
1. Run `bundle install`
1. Run `bundle exec rails db:migrate` to setup the development database and schema.
1. Start the servers, one per terminal window/tab - `bundle exec fcrepo_wrapper`, `bundle exec solr_wrapper`, `bundle exec rails server`, and `bundle exec sidekiq`
### User and workflow setup
1. (optional) Create standard accounts: `bundle exec rails tenejo:standard_users_setup`.
1. Create default collection types: `bundle exec rails hyrax:default_collection_types:create`
1. `bundle exec rails hyrax:default_admin_set:create`

### Testing
1. Start the test servers, one per terminal window / tab - `bundle exec fcrepo_wrapper --config config/fcrepo_wrapper_test.yml`, `bundle exec solr_wrapper --config config/solr_wrapper_test.yml`
1. Run the tests using `bundle exec rspec` or `bundle exec rspec spec/PATH_TO_TEST`

### Production
----------
1. Set `IIIF_SERVER_URL=http://SERVERNAME/cantaloupe/iiif/2/` to use an external cantaloupe IIIF server
