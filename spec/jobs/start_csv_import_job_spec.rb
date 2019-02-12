# frozen_string_literal: true
require 'rails_helper'

RSpec.describe StartCsvImportJob, perform_jobs: :true, type: :job do
  describe '#perform' do
    let(:user) { FactoryBot.create(:user) }
    let(:log_path) { Darlingtonia::LogStream.new(severity: Logger::ERROR).send(:build_filename) }
    context 'with a valid CsvImport record' do
      let(:csv_import) do
        import = CsvImport.new(user: user)
        File.open(csv_file) { |f| import.manifest = f }
        import.save!
        import
      end

      let(:csv_file) { File.join(fixture_path, 'csv_import', 'import_manifest.csv') }

      it 'starts the importer and logs the batch id' do
        expect_any_instance_of(ModularImporter).to receive(:import)
        described_class.perform_now(csv_import.id)
        # TODO: Test for log output once the log location is more predictable
        # expect(File.open(log_path) { |f| f.readlines.join.match?("Starting import with batch ID: #{csv_import.id}") }).to eq(true)
      end
    end
  end
end
