# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Virus Scanning', :clean, :js, :virus_scan, type: :system do
  let(:admin) { FactoryBot.create(:admin) }
  before { login_as admin }
  after  { logout }

  let(:safe_path)  { "#{fixture_path}/images/cat.jpg" }
  let(:virus_path) { "#{fixture_path}/virus_check.txt" }

  scenario 'uploading a file with a virus', :perform_jobs do
    ActiveJob::Base.queue_adapter.filter = [AttachFilesToWorkJob, IngestJob]

    visit('/concern/works/new')
    click_link('Files')

    within('#addfiles') do
      attach_file('files[]', safe_path, visible: false, wait: 5)
      attach_file('files[]', virus_path, visible: false, wait: 5)
    end

    click_link('Descriptions')
    fill_in 'Title', with: 'A Work with a Virus'
    fill_in 'Creator', with: 'Dmitri Ivanovsky'
    fill_in 'Keyword', with: 'pathogens'
    select('No Known Copyright', from: 'Rights')

    allow(Rails.logger).to receive(:error)

    find(:css, '#agreement').set(true)
    click_on('Save')

    visit('/dashboard/my/works')
    click_link('A Work with a Virus')

    expect(Rails.logger)
      .to have_received(:error)
      .with(/Virus.*virus_check\.txt/m)

    # does not attach the virus file; deletes it from disk
    expect(Hyrax::UploadedFile.select { |f| f.file.file.exists? }.count).to eq 1

    # Check that a notification is created
    find(:css, '.notify-number').click
    expect(page).to have_content('virus')
  end
end
