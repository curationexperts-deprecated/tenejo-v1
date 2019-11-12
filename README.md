Tenejo: a General Purpose Digital Repository
============================================

[![CircleCI](https://circleci.com/gh/curationexperts/tenejo.svg?style=svg)](https://circleci.com/gh/curationexperts/tenejo) [![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE) [![Maintainability](https://api.codeclimate.com/v1/badges/11b857b0d512575d91c5/maintainability)](https://codeclimate.com/github/curationexperts/tenejo/maintainability)

Tenejo gives you the most commonly used Samvera features and functions in an easy to use hosted solution.

Hosting
-------

Contact [tenejo@curationexperts.com](mailto:tenejo@curationexperts.com) for information about Tenejo as a managed service for your institution.

Development
-----------

1. `git clone https://github.com/curationexperts/tenejo.git`
1. `cd ./tenejo` then check out a working branch `git checkout -b [meaningful_name]`
1. Ensure you have the prerequisites from https://github.com/samvera/hyrax, although you do not need a separately running Solr or Fedora instance in order to begin in development, since these are packaged with this application, in the form of solr_wrapper and fcrepo_wrapper.
1. Copy `.env.sample` to `.env.development` if you want to override any default settings in your local development environment. Choose a random password for your local tenejo database user and add it to this file.
1. Setup your database.
   We use PostgreSQL. To support the test and development environments, you'll
   need have Postgres installed and running.

    * Create your development and test postgres databases `createdb tenejo_development` and `createdb tenejo_test`
    * Open your psql console in using the newly created tenejo_development database `psql tenejo_development`
    ```
    postgres=# create user tenejo with encrypted password 'whatever';
    CREATE ROLE
    postgres=# grant all privileges on database tenejo_development to tenejo;
    GRANT
    postgres=# grant all privileges on database tenejo_test to tenejo;
    GRANT
    postgres=# ALTER DATABASE tenejo_development OWNER TO tenejo;
    ALTER DATABASE
    postgres=# ALTER DATABASE tenejo_test OWNER TO tenejo;
    postgres=# \q
    ```
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
1. Run `bundle exec rake db:migrate` to setup the development database and schema.
1. (optional) Create standard accounts: `rake tenejo:standard_users_setup`.
1. Create default collection types: `bundle exec rails hyrax:default_collection_types:create`
1. `bundle exec rails hyrax:default_admin_set:create`
1. Start the servers, one per terminal window/tab - `fcrepo_wrapper`, `solr_wrapper`, `rails server`, and `sidekiq`
1. Make sure your computer has a directory /opt/uploads/ that you own


Production
----------
1. Set `IIIF_SERVER_URL=http://SERVERNAME/cantaloupe/iiif/2/` to use an external cantaloupe IIIF server


License
-------

Tenejo is available under the [Apache License Version 2.0](./LICENSE).
