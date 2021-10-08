# frozen_string_literal: true
class CsvImport < ApplicationRecord
  has_one_attached :csv_file
  validate :validate_import

  # If the first several validations return false, we should not continue to try to validate
  # the CSV file
  def validate_import
    return false unless file_attached? # stop if there is no file attached
    return false unless csv_content_type? # stop if the content type is unparseable
    return false unless can_be_parsed? # stop if the file is unparseable
    return false unless required_headers? # stop if the file does not include the correct headers
    return false unless required_rows? # stop unless there's data other than headers in the file
    return false unless duplicate_headers?
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

  private

  def file_attached?
    return true if csv_file.attached?
    errors.add :csv_file, "Must attach a file"
    false
  end

  def csv_content_type?
    content_type = csv_file.content_type
    return true if content_type == "text/plain" || content_type == "text/csv"
    errors.add :csv_file, "Must be a csv file, your file has been determined to be: #{content_type}"
    false
  end

  def can_be_parsed?
    return true if parsed_csv
    errors.add :csv_file, "The file cannot be parsed as a csv"
    false
  end

  # TODO: Should different object types require different headers, as it is currently in Zizia?
  def required_headers?
    missing_headers = default_required_headers - parsed_csv.headers
    return true if missing_headers.empty?
    errors.add :csv_file, "The file is missing required headers. Missing headers are: #{missing_headers.join(', ')}"
    false
  end

  def required_rows?
    size = parsed_csv.size
    rows_with_values = parsed_csv.reject { |row| row.to_hash.values.all?(&:nil?) }
    return true if size.positive? && rows_with_values.count.positive?
    errors.add :csv_file, "The file has no rows with data"
    false
  end

  def duplicate_headers?
    duplicates = parsed_csv.headers.group_by { |e| e }.select { |_k, v| v.size > 1 }.map(&:first)
    return true if duplicates.empty?
    errors.add :csv_file, "The file has duplicate headers. Duplicate headers are: #{duplicates.join(', ')}"
    false
  end
end
