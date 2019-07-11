# coding: utf-8
# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Dashboard', type: :system do
  context 'as a regular user' do
    let(:user) { FactoryBot.create(:user) }

    before do
      login_as user
    end

    it 'the role management page is not accessible' do
      visit('/roles')
      expect(page).to have_content 'not authorized'
    end
  end

  context 'as an admin user' do
    let(:admin) { FactoryBot.create(:admin) }
    let(:user) { FactoryBot.create(:user) }

    before do
      login_as admin
    end

    it 'lets you manage roles' do
      visit('/roles')
      expect(page).to have_content('Roles')
      click_on 'admin'
      fill_in 'User', with: user.email
      click_on 'Add'
      expect(page).to have_content user.email
    end
  end
end
