# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Branding', type: :system do
  context "default banner image" do
    let(:default_image_url) { "banner_image.jpg" }
    it "has a link to the local default banner image" do
      expect(Hyrax.config.banner_image).to eq default_image_url
    end
    context "as an admin user" do
      let(:admin) { FactoryBot.create(:admin) }
      before do
        login_as admin
      end
      it "displays the default branding image" do
        visit('/admin/branding')
        expect(page).to have_content('Banner image')
        expect(page.find('#banner-image')['src']).to match(/banner_image/)
        expect(page).to have_link("Edit")
      end
      it "can navigate to the editing page" do
        visit('/admin/branding')
        click_link("Edit")
        expect(page).to have_content("Upload new banner image")
        page.attach_file("spec/fixtures/images/Everest_Panorama_banner.jpg")
        expect(page).to have_button("Save")
        click_on("Save")
      end
    end

    context "as a non-logged-in user" do
      it "has an unauthorized message" do
        visit('/admin/branding')
        expect(page).to have_content("You are not authorized to access this page")
      end
    end
  end
end
