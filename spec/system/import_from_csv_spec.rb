# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Importing records from a CSV file', type: :system, js: true do
  before { driven_by :selenium_chrome_headless }
  after { driven_by :rack_test }

  let(:csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'extra_headers.csv') }

  context 'logged in as an admin user' do
    let(:collection) { FactoryBot.build(:collection, title: ['Testing Collection']) }
    let(:admin_user) { FactoryBot.create(:admin) }

    before do
      collection.save!
      login_as admin_user
    end

    it 'starts the import' do
      visit new_csv_import_path
      expect(page).to have_content 'Testing Collection'
      expect(page).not_to have_content '["Testing Collection"]'
      select 'Testing Collection', from: "csv_import[fedora_collection_id]"

      # Fill in and submit the form
      attach_file('csv_import[manifest]', csv_file, make_visible: true)
      click_on 'Preview Import'

      # We expect to see warnings for this CSV file.
      expect(page).to have_content 'The field name "another_header_1" is not supported'

      # We expect to see the title of the collection on the page
      expect(page).to have_content 'Testing Collection'

      expect(page).to have_content 'This import will add 3 new records.'

      # There is a link so the user can cancel.
      expect(page).to have_link 'Cancel', href: new_csv_import_path(locale: I18n.locale)

      # After reading the warnings, the user decides
      # to continue with the import.
      click_on 'Start Import'

      # The show page for the CsvImport
      expect(page).to have_content 'extra_headers.csv'
      expect(page).to have_content 'Start time'

      # We expect to see the title of the collection on the page
      expect(page).to have_content 'Testing Collection'

      # TODO: Check that the import got kicked off.
      # e.g. Check that a job got queued.
      # Or, let the background jobs run, and check that the expected number of records got created.
    end
  end
end
