Tenejo: a General Purpose Digital Repository
============================================

[![Build Status](https://travis-ci.org/curationexperts/tenejo.svg?branch=master)](https://travis-ci.org/curationexperts/tenejo) [![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)

Tenejo gives you the most commonly used Samvera features and functions in an easy to use hosted solution.

Hosting
-------

Contact [tenejo@curationexperts.com](mailto:tenejo@curationexperts.com) for information about Tenejo as a managed service for your institution.

Development
-----------
1. Copy `.env.sample`
  This application uses `dotenv` to set environment variables. To set this up locally,
  copy the sample file to set values for your local test and development environments.
  ```
  cp .env.sample .env.test
  cp .env.sample .env.development
  ```
  Edit these files as appropriate. Most notably, you will want a different database
  name for development vs test.

1. Setup your databases.
   We use PostgreSQL. To support the test and development environments, you'll
   need have Postgres installed and running. In your `psql` console do
   `create role tenejo with createdb login`. Then do
   `bundle exec rake db:setup` to setup the create the database and schema.

License
-------

Tenejo is available under the [Apache License Version 2.0](./LICENSE).
