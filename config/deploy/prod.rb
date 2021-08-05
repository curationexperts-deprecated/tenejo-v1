# frozen_string_literal: true
server ENV['TARGET'], user: 'deploy', roles: [:web, :app, :db]
