# frozen_string_literal: true

require 'rails_helper'
require 'active_fedora/cleaner'

RSpec.describe ModularImporter, :clean do
  let(:modular_csv) { 'spec/fixtures/csv_import/modular_input.csv' }
  let(:user) { ::User.batch_user }
  let(:collection) { FactoryBot.create(:collection) }

  before do
    ENV['IMPORT_PATH'] = File.expand_path('../fixtures/images', File.dirname(__FILE__))
  end

  it "imports a csv" do
    expect { ModularImporter.new(modular_csv, collection.id).import }.to change { Work.count }.by 3
  end

  it "puts the title into the title field" do
    ModularImporter.new(modular_csv, collection.id).import
    expect(Work.where(title: 'A Cute Dog').count).to eq 1
  end

  it "puts the url into the source field" do
    ModularImporter.new(modular_csv, collection.id).import
    expect(Work.where(source: 'https://www.pexels.com/photo/animal-blur-canine-close-up-551628/').count).to eq 1
  end

  it "creates publicly visible objects" do
    ModularImporter.new(modular_csv, collection.id).import
    imported_work = Work.first
    expect(imported_work.visibility).to eq 'open'
  end

  it "attaches files" do
    allow(AttachFilesToWorkJob).to receive(:perform_later)
    ModularImporter.new(modular_csv, collection.id).import
    expect(AttachFilesToWorkJob).to have_received(:perform_later).exactly(3).times
  end

  it "adds the new record to the collection" do
    expect(Work.count).to eq 0
    ModularImporter.new(modular_csv, collection.id).import
    work = Work.first
    expect(work.member_of_collections).to eq [collection]
  end
end
