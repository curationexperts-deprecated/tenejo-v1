# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'the homepage', type: :system, js: false do
  let(:test_strategy) { Flipflop::FeatureSet.current.test! }

  context "as admin user" do
    let(:admin) { FactoryBot.create(:admin) }

    before do
      login_as admin
    end
    it 'does not have a researcher tab' do
      visit '/'
      expect(page).not_to have_content 'Featured Researcher'
    end

    context "using the new ui" do
      before do
        test_strategy.switch!(:new_ui, true)
      end
      it 'does not have a share your work button' do
        allow_any_instance_of(Hyrax::HomepagePresenter).to receive(:display_share_button?).and_return(true)
        visit '/'
        expect(page).not_to have_link(I18n.t('hyrax.share_button'))
      end
    end
    context 'using the old ui' do
      before do
        test_strategy.switch!(:new_ui, false)
      end

      it 'has a share your work button' do
        allow_any_instance_of(Hyrax::HomepagePresenter).to receive(:display_share_button?).and_return(true)
        visit '/'
        expect(page).to have_link(I18n.t('hyrax.share_button'))
      end
    end
  end
end
