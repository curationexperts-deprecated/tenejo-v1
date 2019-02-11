# frozen_string_literal: true
require 'darlingtonia'

class ModularImporter
  def initialize(csv_import)
    @csv_file = csv_import.manifest.to_s
    @collection_id = csv_import.fedora_collection_id
    @user_id = csv_import.user_id
    @user_email = User.find(csv_import.user_id).email
  end

  def import
    raise "Cannot find expected input file #{@csv_file}" unless File.exist?(@csv_file)

    attrs = {
      collection_id: @collection_id,
      depositor_id: @user_id
    }

    file = File.open(@csv_file)

    Darlingtonia.config.default_info_stream << "Import for collection: #{@collection_id} started by #{@user_email}\n"

    Darlingtonia::Importer.new(parser: Darlingtonia::CsvParser.new(file: file), record_importer: Darlingtonia::HyraxRecordImporter.new(attributes: attrs)).import

    file.close
  end
end
