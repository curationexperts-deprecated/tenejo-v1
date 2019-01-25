# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CsvImport, type: :model do
  subject(:csv_import) { described_class.new }

  it 'has a CSV manifest' do
    expect(csv_import.manifest).to be_a CsvManifestUploader
  end

  context '#queue_start_job' do
    it 'queues a job to start the import' do
      expect {
        csv_import.queue_start_job
      }.to have_enqueued_job(StartCsvImportJob)
    end
  end
end
