# frozen_string_literal: true
require 'darlingtonia'

class ModularImporter
  def initialize(csv_file, collection_id)
    @csv_file = csv_file
    @collection_id = collection_id
  end

  def import
    raise "Cannot find expected input file #{@csv_file}" unless File.exist?(@csv_file)

    file = File.open(@csv_file)
    Darlingtonia::Importer.new(parser: Darlingtonia::CsvParser.new(file: file), record_importer: Darlingtonia::HyraxRecordImporter.new(collection_id: @collection_id)).import
    file.close
  end
end
