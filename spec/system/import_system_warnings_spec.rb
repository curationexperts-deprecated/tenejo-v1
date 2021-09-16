# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Showing background services warnings on import page', :perform_jobs, :clean, type: :system, js: true do
  let(:admin_user) { FactoryBot.create(:admin) }
  let(:antivirus_warning) { 'WARNING: antivirus is not configured correctly, please contact your system administrator' }
  let(:image_conversion_warning) { "WARNING: image conversion is not configured correctly, please contact your system administrator" }
  let(:audiovisual_warning) { "WARNING: media processing is not configured correctly, please contact your system administrator" }
  let(:background_processing_warning) { "WARNING: background processing is not configured correctly, please contact your system administrator" }
  let(:file_characterization_warning) { "WARNING: file characterization is not configured correctly, please contact your system administrator" }

  before do
    login_as admin_user
  end

  context "with characterization software" do
    it "does display warning when absent" do
      allow_any_instance_of(ServicesHelper).to receive(:check_characterization).and_return(false)
      visit '/csv_imports/new'
      expect(page).to have_content 'Batch Import'
      expect(page).to have_content file_characterization_warning
    end

    it "does not display warning when present" do
      allow_any_instance_of(ServicesHelper).to receive(:check_characterization).and_return(true)
      visit '/csv_imports/new'
      expect(page).to have_content 'Batch Import'
      expect(page).not_to have_content file_characterization_warning
    end
  end

  context "with audiovisual software" do
    context "running" do
      it "does not show a warning" do
        allow_any_instance_of(ServicesHelper).to receive(:check_audiovisual_conversion).and_return(true)

        visit '/csv_imports/new'
        expect(page).to have_content 'Batch Import'
        expect(page).not_to have_content audiovisual_warning
      end
    end

    context "broken" do
      it "shows a warning" do
        allow_any_instance_of(ServicesHelper).to receive(:check_audiovisual_conversion).and_return(false)

        visit '/csv_imports/new'
        expect(page).to have_content 'Batch Import'
        expect(page).to have_content audiovisual_warning
      end
    end
  end

  context "with antivirus" do
    context "stopped" do
      before do
        class_double("Clamby").as_stubbed_const
        allow(Clamby).to receive(:safe?).and_return(false)
      end
      it "shows a warning on the page" do
        allow_any_instance_of(ServicesHelper).to receive(:check_antivirus_service).and_return(false)

        visit '/csv_imports/new'
        expect(page).to have_content 'Batch Import'
        expect(page).to have_content antivirus_warning
      end
    end

    context "running" do
      it "does not show a warning about antivirus" do
        allow_any_instance_of(ServicesHelper).to receive(:check_antivirus_service).and_return(true)

        visit '/csv_imports/new'
        expect(page).to have_content 'Batch Import'
        expect(page).not_to have_content antivirus_warning
      end
    end
  end

  context "with image conversion software" do
    context "running" do
      it "does not show a warning" do
        allow_any_instance_of(ServicesHelper).to receive(:check_image_conversion).and_return(true)

        visit '/csv_imports/new'
        expect(page).to have_content 'Batch Import'
        expect(page).not_to have_content image_conversion_warning
      end
    end

    context "broken" do
      it "shows a warning" do
        allow_any_instance_of(ServicesHelper).to receive(:check_image_conversion).and_return(false)

        visit '/csv_imports/new'
        expect(page).to have_content 'Batch Import'
        expect(page).to have_content image_conversion_warning
      end
    end
  end

  context "with background job processing software" do
    context "both sidekiq and redis running" do
      it "does not show a warning" do
        allow_any_instance_of(ServicesHelper).to receive(:check_sidekiq).and_return(true)
        allow_any_instance_of(ServicesHelper).to receive(:check_redis).and_return(true)

        visit '/csv_imports/new'
        expect(page).to have_content 'Batch Import'
        expect(page).not_to have_content background_processing_warning
      end
    end
    context "sidekiq stopped and redis running" do
      it "shows a warning" do
        allow_any_instance_of(ServicesHelper).to receive(:check_sidekiq).and_return(false)
        allow_any_instance_of(ServicesHelper).to receive(:check_redis).and_return(true)

        visit '/csv_imports/new'
        expect(page).to have_content 'Batch Import'
        expect(page).to have_content background_processing_warning
      end
    end
    context "redis stopped and sidekiq running" do
      it "shows a warning" do
        allow_any_instance_of(ServicesHelper).to receive(:check_sidekiq).and_return(true)
        allow_any_instance_of(ServicesHelper).to receive(:check_redis).and_return(false)

        visit '/csv_imports/new'
        expect(page).to have_content 'Batch Import'
        expect(page).to have_content background_processing_warning
      end
    end
  end

  context "with software broken or misconfigured" do
    it "shows warnings for each service that is not working" do
      allow_any_instance_of(ServicesHelper).to receive(:check_antivirus_service).and_return(false)
      allow_any_instance_of(ServicesHelper).to receive(:check_audiovisual_conversion).and_return(false)
      allow_any_instance_of(ServicesHelper).to receive(:check_image_conversion).and_return(false)

      visit '/csv_imports/new'
      expect(page).to have_content 'Batch Import'
      expect(page).to have_content antivirus_warning
      expect(page).to have_content audiovisual_warning
      expect(page).to have_content image_conversion_warning
    end
  end
end
