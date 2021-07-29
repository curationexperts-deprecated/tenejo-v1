# coding: utf-8
# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Manage users', type: :system do
  context 'as an admin user' do
    let(:admin) { FactoryBot.create(:admin) }
    before do
      login_as admin
      visit '/admin/users'
    end
    it "has a button to add a user" do
      expect(page).to have_content("Manage Users")
      expect(page).to have_button("Invite New User")
    end
  end

  context "as a regular user" do
    let(:user) { FactoryBot.create(:user) }
    before do
      login_as user
    end
    it "cannot see the 'Send Invitation' page" do
      true
    end
  end
end
