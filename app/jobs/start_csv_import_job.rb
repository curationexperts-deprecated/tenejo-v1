# frozen_string_literal: true

class StartCsvImportJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(csv_import_id)
    csv_import = CsvImport.find csv_import_id
    csv_file_path = csv_import.manifest.to_s
    importer = ModularImporter.new(csv_file_path, csv_import.fedora_collection_id)
    importer.import
  end
end
