# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Banner', type: :system do
  context "default banner image" do
    let(:default_image_url) { "assets/tenejo_books.jpg" }
    it "has a link to the local default banner image" do
      expect(Hyrax.config.banner_image).to eq default_image_url
    end
    context "as an admin user" do
      let(:admin) { FactoryBot.create(:admin) }
      before do
        login_as admin
      end
      it "has a way to upload a new banner image" do
        visit('/admin/branding')
        expect(page).to have_content("Upload")
      end
    end

    context "as a non-logged-in user" do
      it "has an unauthorized message" do
        visit('/admin/branding')
        expect(page).not_to have_content("Upload")
      end
    end
  end
end
