# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModularImporter, :clean do
  let(:modular_csv) { 'spec/fixtures/csv_import/good/all_fields.csv' }
  let(:user) { ::User.batch_user }
  let(:collection) { FactoryBot.build(:collection) }
  let(:csv_import) do
    import = Zizia::CsvImport.new(user: user, fedora_collection_id: collection.id)
    import.update_actor_stack = 'HyraxDefault'
    File.open(modular_csv) { |f| import.manifest = f }
    import
  end

  before do
    ENV['IMPORT_PATH'] = File.join(fixture_path, 'images')
  end

  it "imports a csv" do
    expect { ModularImporter.new(csv_import).import }.to change { Work.count }.by 2

    # We can't guarantee that background jobs create this
    # arrangement currently.
    expect(Work.first.title.first).to match(/terior view/)
    expect(Work.last.title.first).to match(/terior view/)
  end
end
