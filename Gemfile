# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.7.4'

gem 'bcrypt_pbkdf', '~> 1.1' # Needed to support more secure ssh keys
gem 'capistrano-passenger'
gem 'clamby'
gem 'coffee-rails', '~> 4.2' # Use CoffeeScript for .coffee assets and views
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'devise_invitable', '~> 2.0.0'
gem 'dotenv-rails', '~> 2.2.1'
gem 'ed25519'
gem 'honeybadger', '~> 4.0'
gem 'hydra-role-management', '~> 1.0.0'
gem 'hyrax', '~> 2.9'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'loofah', '>= 2.2.3'
gem 'nokogiri', '>= 1.12.5'
gem 'open3', '~> 0.1.0'
gem 'pg', '~> 1.0'
gem 'puma', '~> 4.3' # Use Puma as the app server
gem 'rails', '~> 5.2.6'
gem 'redcarpet', '>= 3.5.1'
gem 'riiif', '~> 1.1'
gem 'rsolr', '>= 1.0'
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'sidekiq', '5.2.7'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'whenever', require: false
gem 'zizia', git: 'https://github.com/curationexperts/zizia', tag: 'v7.0.0'

group :development do
  # Use Capistrano for deployment automation
  gem "capistrano", "~> 3.16", require: false
  gem 'capistrano-bundler', '~> 2.0'
  gem 'capistrano-ext'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq', '~> 1.0.3'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'pry'
  gem 'pry-byebug'
  gem 'web-console', '>= 3.3.0'
  gem 'xray-rails'
end

group :development, :test do
  gem 'bixby', '~> 3.0'
  gem 'rubocop'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'fcrepo_wrapper'
  gem 'ffaker'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rspec-retry'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'solr_wrapper', '>= 0.3'
  gem 'webdrivers'
end
