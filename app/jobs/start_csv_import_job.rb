# frozen_string_literal: true

class StartCsvImportJob < ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(csv_import_id)
    csv_import = CsvImport.find csv_import_id
    importer = ModularImporter.new(csv_import)
    importer.import
  end
end
