# frozen_string_literal: true
require 'darlingtonia'

class ModularImporter
  def initialize(csv_file)
    @csv_file = csv_file
    raise "Cannot find expected input file #{csv_file}" unless File.exist?(csv_file)
  end

  def import
    file = File.open(@csv_file)
    Darlingtonia::Importer.new(parser: Darlingtonia::CsvParser.new(file: file), record_importer: Darlingtonia::HyraxRecordImporter.new).import
    file.close
  end
end
