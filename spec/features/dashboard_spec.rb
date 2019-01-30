# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Dashboard' do
  context 'as a regular user' do
    let(:user) { FactoryBot.create(:user) }

    before do
      login_as user
      visit '/dashboard'
    end

    scenario 'can download a CSV template' do
      expect(page).to have_link 'Download CSV Template'
    end

    scenario 'can get to the importer page' do
      expect(page).to have_link 'Import Content From a CSV'
    end
  end
end
