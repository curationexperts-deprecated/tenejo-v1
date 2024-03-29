#!/bin/bash

/etc/init.d/clamav-freshclam start
/etc/init.d/clamav-daemon start
bundle check || bundle install
find . -name *.pid -delete
bundle exec rake db:create && bundle exec rake db:migrate
bundle exec rake tenejo:standard_users_setup
bundle exec rails hyrax:default_collection_types:create
bundle exec rails hyrax:default_admin_set:create
bundle exec sidekiq --daemon
bundle exec rails s -b 0.0.0.0
