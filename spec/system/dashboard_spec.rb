# coding: utf-8
# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Dashboard', type: :system do
  context 'as a regular user' do
    let(:user) { FactoryBot.create(:user) }

    before do
      login_as user
      visit '/dashboard'
    end

    it 'can download a CSV template' do
      expect(page).to have_link 'Download CSV Template'
    end

    it 'can get to the importer page' do
      expect(page).to have_link 'Import Content From a CSV'
    end

    it 'has the footer version' do
      expect(page).to have_content ENV['DEPLOYED_VERSION']
    end
  end
end
