# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'Not having a contact form', type: :system do
  context 'visiting the contact form directly' do
    it 'has a 404 page' do
      visit('/contact')
      expect(page).to have_content('does not exist')
    end
  end

  context 'in the navbar' do
    it 'does not have a link' do
      visit('/')
      expect(page).not_to have_link('Contact')
    end
  end
end
