# frozen_string_literal: true

require 'rails_helper'
require 'active_fedora/cleaner'

RSpec.describe ModularImporter, :clean do
  let(:modular_csv) { 'spec/fixtures/csv_import/modular_input.csv' }
  let(:user) { ::User.batch_user }
  let(:collection) { FactoryBot.create(:collection) }
  let(:csv_import) do
    import = CsvImport.new(user: user, fedora_collection_id: collection.id)
    File.open(modular_csv) { |f| import.manifest = f }
    import
  end
  let(:log_path) { Darlingtonia::LogStream.new(severity: Logger::INFO).send(:build_filename) }

  before do
    ENV['IMPORT_PATH'] = File.expand_path('../fixtures/images', File.dirname(__FILE__))
    allow_any_instance_of(::Ability).to receive(:can?).and_return(true)
  end

  context "importing the same object twice" do
    let(:first_csv_file)   { File.join(fixture_path, 'csv_import', 'good', 'all_fields.csv') }
    let(:first_csv_import) do
      import = CsvImport.new(user: user, fedora_collection_id: collection.id)
      File.open(first_csv_file) { |f| import.manifest = f }
      import
    end
    let(:first_importer) { ModularImporter.new(first_csv_import) }
    let(:second_csv_file)  { File.join(fixture_path, 'csv_import', 'good', 'all_fields_update.csv') }
    let(:second_csv_import) do
      import = CsvImport.new(user: user, fedora_collection_id: collection.id)
      File.open(second_csv_file) { |f| import.manifest = f }
      import
    end
    let(:second_importer) { ModularImporter.new(second_csv_import) }
    it 'updates existing records if the ARK matches' do
      first_importer.import
      work = Work.last
      expect(work.keyword).to eq ["Clothing stores $z California $z Los Angeles", "Interior design $z California $z Los Angeles"]
      second_importer.import
      work.reload
      expect(work.keyword.first).to eq "New Keyword"
    end
  end

  it "imports a CSV with the correct metadata" do
    expect {
      ModularImporter.new(csv_import).import
    }.to change { Work.count }.to 3

    work = Work.where(title: 'A Cute Dog').first
    expect(work.source).to eq ['https://www.pexels.com/photo/animal-blur-canine-close-up-551628/']
    expect(work.visibility).to eq 'open'
    expect(work.rights_statement).to eq ['http://rightsstatements.org/vocab/InC/1.0/']
    expect(work.description).to contain_exactly('dog photo', 'some kind of spaniel?')
    expect(work.date_created).to eq ['2018']
    expect(work.based_near.first.class).to eq Hyrax::ControlledVocabularies::Location
    expect(work.related_url).to eq ['https://www.pexels.com/']
    expect(work.resource_type).to eq ['Image']
    expect(work.creator).to eq ['Kat Jayne']
  end

  it "attaches files" do
    allow(AttachFilesToWorkJob).to receive(:perform_later)

    ModularImporter.new(csv_import).import
    expect(AttachFilesToWorkJob).to have_received(:perform_later).exactly(3).times
  end

  it "adds the new record to the collection" do
    expect(Work.count).to eq 0
    ModularImporter.new(csv_import).import
    work = Work.first
    expect(work.member_of_collections).to eq [collection]
  end

  it 'logs the collection and user id' do
    # TODO: Test for log output once the log location is more predictable
    skip
    File.delete(log_path)
    ModularImporter.new(csv_import).import
    expect(File.open(log_path) { |f| f.readlines.join.match?("event: start_import, batch_id: , collection_id: #{collection.id}, user: #{user.email}") }).to eq(true)
  end
end
