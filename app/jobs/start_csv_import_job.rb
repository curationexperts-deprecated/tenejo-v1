# frozen_string_literal: true

class StartCsvImportJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(csv_import_id)
    csv_import = CsvImport.find csv_import_id
    log_stream = Tenejo::LogStream.new
    log_stream << "Starting import with batch ID: #{csv_import_id}"
    importer = ModularImporter.new(csv_import, log_stream: log_stream)
    importer.import
  end
end
