# frozen_string_literal: true
class CsvImport < ApplicationRecord
  has_one_attached :csv_file
  validate :validate_import

  def validate_import
    return validate_attached unless validate_attached
    return validate_content_type unless validate_content_type
    return validate_parsing unless validate_parsing
    return validate_headers unless validate_headers
  end

  def validate_attached
    if csv_file.attached?
      true
    else
      errors.add :csv_file, "Must attach a file"
      false
    end
  end

  def validate_content_type
    content_type = csv_file.content_type
    return true if content_type == "text/plain" || content_type == "text/csv"
    errors.add :csv_file, "Must be a csv file, your file has been determined to be: #{content_type}"
    false
  end

  def validate_parsing
    return true if parsed_csv
    false
  end

  # TODO: Should different object types require different headers, as it is currently in Zizia?
  def validate_headers
    missing_headers = default_required_headers - parsed_csv.headers
    return true if missing_headers.empty?
    errors.add :csv_file, "The file is missing required headers. Missing headers are: #{missing_headers}"
    false
  end

  def parsed_csv
    @parsed_csv ||= CSV.parse(downloaded_csv, headers: true, header_converters: :symbol)
  end

  def downloaded_csv
    @downloaded_csv ||= csv_file.download
  end

  def default_required_headers
    [:title, :creator, :keyword, :rights_statement, :visibility, :files, :deduplication_key]
  end
end
