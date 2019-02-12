# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Importing records from a CSV file', :perform_jobs, :clean, type: :system, js: true do
  let(:csv_file) { File.join(fixture_path, 'csv_import', 'good', 'all_fields.csv') }

  context 'logged in as an admin user' do
    let(:collection) { FactoryBot.build(:collection, title: ['Testing Collection']) }
    let(:admin_user) { FactoryBot.create(:admin) }

    before do
      allow(CharacterizeJob).to receive(:perform_later) # There is no fits installed on travis-ci
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
      expect(page).to have_content 'all_fields.csv'
      click_on 'Preview Import'

      # We expect to see the title of the collection on the page
      expect(page).to have_content 'Testing Collection'

      expect(page).to have_content 'This import will add 1 new records.'

      # There is a link so the user can cancel.
      expect(page).to have_link 'Cancel', href: new_csv_import_path(locale: I18n.locale)

      # After reading the warnings, the user decides
      # to continue with the import.
      click_on 'Start Import'

      # The show page for the CsvImport
      expect(page).to have_content 'all_fields.csv'
      expect(page).to have_content 'Start time'

      # We expect to see the title of the collection on the page
      expect(page).to have_content 'Testing Collection'

      # Let the background jobs run, and check that the expected number of records got created.
      expect(Work.count).to eq 1

      # Ensure that all the fields got assigned as expected
      work = Work.where(title: "*haberdashery*").first
      expect(work.title.first).to match(/haberdashery/)

      # Ensure location (a.k.a. based_near) gets turned into a controlled vocabulary term
      expect(work.based_near.first.class).to eq Hyrax::ControlledVocabularies::Location

      # It sets the date_uploaded field
      expect(work.date_uploaded.class).to eq DateTime

      # Ensure visibility gets turned into expected Hyrax values (e.g., 'PUBlic' becomes 'open')
      expect(work.visibility).to eq 'open'

      # Ensure work is being added to the collection as expected
      expect(work.member_of_collection_ids).to eq [collection.id]

      visit "/concern/works/#{work.id}"
      expect(page).to have_content work.title.first
      # Controlled vocabulary location should have been resolved to its label name
      expect(page).to have_content "Montana"
      expect(page).to have_content "United States"
    end
  end
end
