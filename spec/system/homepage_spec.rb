# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'the homepage', type: :system do
  it 'does not have a researcher tab' do
    visit '/'
    expect(page).not_to have_content 'Featured Researcher'
  end
end
