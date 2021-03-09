#!/bin/bash

bundle check || bundle install
find . -name *.pid -delete
bundle exec rake db:create && bundle exec rake db:migrate
bundle exec rails s -b 0.0.0.0
