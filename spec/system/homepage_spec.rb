# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'the homepage', type: :system do
  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:collection_type) { Hyrax::CollectionType.find_or_create_default_collection_type }
  before do
    admin_set_id
    collection_type
    visit '/'
  end

  context "as admin user" do
    let(:admin) { FactoryBot.create(:admin) }

    before do
      login_as admin
    end
    it 'does not have a researcher tab' do
      expect(page).not_to have_content 'Featured Researcher'
    end
  
    context "using the new ui" do
      before do
        test_strategy = Flipflop::FeatureSet.current.test!
        test_strategy.switch!(:new_ui, true)
      end
      it 'does not have a share your work button' do
        expect(page).not_to have_button 'Share Your Work'  
      end
    end
    context 'using the old ui' do
      before do
        test_strategy = Flipflop::FeatureSet.current.test!
        test_strategy.switch!(:new_ui, false)
      end
      it 'has a share your work button' do
        # byebug
        expect(page).to have_button 'Share Your Work'  
        
      end
    end
  end
  

end
