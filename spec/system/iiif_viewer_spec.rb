# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'iiif viewer', type: :system, js: true do
  let(:work_path) { "/concern/works/#{work.id}" }

  before do
    create(:sipity_entity, proxy_for_global_id: work.to_global_id.to_s)
  end

  context "as the work owner" do
    let(:work) do
      create(:public_work,
             with_admin_set: true,
             title: ["Magnificent splendor", "Happy little trees"],
             source: ["The Internet"],
             based_near: ["USA"],
             user: user,
             ordered_members: [file_set],
             representative_id: file_set.id)
    end
    let(:user) { create(:user) }
    let(:file_set) { create(:file_set, :public, user: user, title: ['A Contained FileSet'], content: file) }
    let(:file) { File.open(fixture_path + '/images/dog.jpg') }
    let(:multi_membership_type_1) { create(:collection_type, :allow_multiple_membership, title: 'Multi-membership 1') }
    let!(:collection) { create(:collection_lw, user: user, collection_type_gid: multi_membership_type_1.gid) }
    let(:user) { FactoryBot.create(:admin) }
    before do
      login_as user
      visit work_path
    end

    it "runs the test" do
      expect(page).to have_content('Magnificent splendor')
      expect(work.read_groups).to match_array(["public"])
      expect(work.file_sets.first.read_groups).to match_array(["public"])
      expect(work.representative_id).to eq work.file_sets.first.id
      expect(page).to have_css('.uv')
      expect(page).to have_button("Hide image viewer")
    end

  end
end
