# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Importing records from a CSV file', type: :system, js: true do
  before { driven_by :selenium_chrome_headless }
  after { driven_by :rack_test }

  let(:csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'extra_headers.csv') }

  context 'logged in as an admin user' do
    let(:admin_user) { FactoryBot.create(:admin) }
    before { login_as admin_user }

    it 'starts the import' do
      visit new_csv_import_path

      # Fill in and submit the form
      attach_file('csv_import[manifest]', csv_file)
      click_on 'Preview Import'

      # We expect to see warnings for this CSV file.
      expect(page).to have_content 'The field name "another_header_1" is not supported'

      # There is a link so the user can cancel.
      expect(page).to have_link 'Cancel', href: new_csv_import_path(locale: I18n.locale)

      # After reading the warnings, the user decides
      # to continue with the import.
      click_on 'Start Import'

      # The show page for the CsvImport
      expect(page).to have_content 'extra_headers.csv'
      expect(page).to have_content 'Start time'

      # TODO: Check that the import got kicked off.
      # e.g. Check that a job got queued.
      # Or, let the background jobs run, and check that the expected number of records got created.
    end
  end
end
