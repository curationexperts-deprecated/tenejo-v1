# frozen_string_literal: true
require 'rails_helper'

include Warden::Test::Helpers

RSpec.describe 'Read Only Mode', type: :system do
  let(:user) { create :user }

  context 'a logged in user' do
    before do
      login_as user
    end

    scenario "Creating a work with read only mode enabled and disabled", js: false do
      visit("/concern/works/new")
      expect(page).to have_content("Add New Work")
      allow(Flipflop).to receive(:read_only?).and_return(true)
      visit("/concern/works/new")
      expect(page).to have_content("This system is in read-only mode for maintenance.")
      allow(Flipflop).to receive(:read_only?).and_return(false)
      visit("/concern/works/new")
      expect(page).to have_content("Add New Work")
    end
  end
end
