# frozen_string_literal: true
# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'rspec/retry'
require 'active_fedora/cleaner'
require 'ffaker'
require 'selenium-webdriver'
require 'simplecov'
SimpleCov.start unless ENV['NOCOV']
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f } # rubocop:disable Rails/FilePath

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    ActiveJob::Base.queue_adapter = :test
    ActiveFedora::Cleaner.clean!
  end

  config.before(clean: true) do
    ActiveFedora::Cleaner.clean!
  end

  config.before do |_example|
    class_double("Clamby").as_stubbed_const
    allow(Clamby).to receive(:virus?).and_return(false)
    allow(Clamby).to receive(:safe?).and_return(true)
  end

  # We use an EICAR-STANDARD-ANTIVIRUS-TEST-FILE, but when stubbing virus checks
  # we can just check the filename.
  RSpec::Matchers.define :a_virus_test_file do
    match do |actual|
      path = actual.respond_to?(:path) ? actual.path : actual
      File.basename(path) == 'virus_check.txt'
    end
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before(virus_scan: true) do
    allow(Clamby).to receive(:virus?).with(a_virus_test_file).and_return(true)
  end

  config.include Devise::Test::ControllerHelpers, type: :controller

  config.before perform_jobs: true do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
  end

  config.after perform_jobs: true do
    ActiveJob::Base.queue_adapter.filter                = nil
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = false
  end

  # Retry ReadTimeout errors
  #  config.verbose_retry = true
  config.default_retry_count = 1 # for now
  # Retry when Selenium raises Net::ReadTimeout
  # Retry when trying to access something in Fedroa that doesn't exist yet
  config.exceptions_to_retry = [Net::ReadTimeout, Ldp::HttpError]
end
