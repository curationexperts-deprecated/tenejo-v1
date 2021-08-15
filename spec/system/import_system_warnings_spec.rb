# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Showing background services warnings on import page', :perform_jobs, :clean, type: :system, js: true do
  let(:admin_user) { FactoryBot.create(:admin) }
  let(:antivirus_warning) { 'WARNING: antivirus is not configured correctly, please contact your system administrator' }
  let(:image_conversion_warning) { "WARNING: image conversion is not configured correctly, please contact your system administrator" }
  let(:audiovisual_warning) { "WARNING: media processing is not configured correctly, please contact your system administrator" }

  before do
    login_as admin_user
  end

  context "with audiovisual software running" do
    it "does not show a warning about audiovisual software configuration" do
      allow_any_instance_of(Zizia::CsvImportsController).to receive(:check_audiovisual_conversion).and_return("all sorts of codecs")

      visit '/csv_imports/new'
      expect(page).to have_content 'Batch Import'
      expect(page).not_to have_content audiovisual_warning
    end
  end

  context "with audiovisual software broken" do
    it "shows a warning about audiovisual software configuration" do
      allow_any_instance_of(Zizia::CsvImportsController).to receive(:check_audiovisual_conversion).and_return("")

      visit '/csv_imports/new'
      expect(page).to have_content 'Batch Import'
      expect(page).to have_content audiovisual_warning
    end
  end
  context "with antivirus stopped" do
    it "shows a warning on the page" do
      allow_any_instance_of(Zizia::CsvImportsController).to receive(:list_antivirus_service).and_return("")
      visit '/csv_imports/new'
      expect(page).to have_content 'Batch Import'
      expect(page).to have_content antivirus_warning
    end
  end

  context "with image conversion software running" do
    it "does not show a warning about image configuration" do
      allow_any_instance_of(Zizia::CsvImportsController).to receive(:check_image_conversion).and_return(true)

      visit '/csv_imports/new'
      expect(page).to have_content 'Batch Import'
      expect(page).not_to have_content image_conversion_warning
    end
  end

  context "with image conversion software broken" do
    it "shows a warning" do
      allow_any_instance_of(Zizia::CsvImportsController).to receive(:check_image_conversion).and_return(false)

      visit '/csv_imports/new'
      expect(page).to have_content 'Batch Import'
      expect(page).to have_content image_conversion_warning
    end
  end

  context "with antivirus running" do
    it "does not show a warning about antivirus" do
      allow_any_instance_of(Zizia::CsvImportsController).to receive(:list_antivirus_service).and_return("472 ? Ssl 0:00 /usr/sbin/clamd -c /etc/clamav/clamd.conf --pid=/run/clamav/clamd.pid")
      visit '/csv_imports/new'
      expect(page).not_to have_content antivirus_warning
    end
  end
end
