# frozen_string_literal: true
class CsvImportValidator < ActiveModel::Validator
  # If the first several validations return false, we should not continue to try to validate
  # the CSV file
  def validate(record)
    return false unless file_level_valid?(record)
    return false unless column_level_valid?(record)
    return false unless row_level_valid?(record)
    true
  end

  private

  def file_level_valid?(record)
    return false unless file_attached?(record) # stop if there is no file attached
    return false unless csv_content_type?(record) # stop if the content type is unparseable
    return false unless can_be_parsed?(record) # stop if the file is unparseable
    return false unless required_rows?(record) # stop unless there's data other than headers in the file
    true
  end

  def column_level_valid?(record)
    return false unless required_headers?(record) # stop if the file does not include the correct headers
    return false unless duplicate_headers?(record)
    true
  end

  def row_level_valid?(record)
    return false unless mismatched_headers_and_columns(record)
    true
  end

  def file_attached?(record)
    return true if record.csv_file.attached?
    record.errors.add :csv_file, "Must attach a file"
    false
  end

  def csv_content_type?(record)
    content_type = record.csv_file.content_type
    return true if content_type == "text/plain" || content_type == "text/csv"
    record.errors.add :csv_file, "Must be a csv file, your file has been determined to be: #{content_type}"
    false
  end

  def can_be_parsed?(record)
    return true if record.parsed_csv
    record.errors.add :csv_file, "The file cannot be parsed as a csv"
    false
  end

  # TODO: Should different object types require different headers, as it is currently in Zizia?
  def required_headers?(record)
    missing_headers = record.default_required_headers - record.parsed_csv.headers
    return true if missing_headers.empty?
    record.errors.add :csv_file, "The file is missing required headers. Missing headers are: #{missing_headers.join(', ')}"
    false
  end

  def required_rows?(record)
    size = record.parsed_csv.size
    rows_with_values = record.parsed_csv.reject { |row| row.to_hash.values.all?(&:nil?) }
    return true if size.positive? && rows_with_values.count.positive?
    record.errors.add :csv_file, "The file has no rows with data"
    false
  end

  def duplicate_headers?(record)
    duplicates = record.parsed_csv.headers.group_by { |e| e }.select { |_k, v| v.size > 1 }.map(&:first)
    return true if duplicates.empty?
    record.errors.add :csv_file, "The file has duplicate headers. Duplicate headers are: #{duplicates.join(', ')}"
    false
  end

  def mismatched_headers_and_columns(record)
    header_count = record.parsed_csv.headers.count
    rows_with_unmatched_length = record.parsed_csv.select { |row| row.length != header_count }
    return true if rows_with_unmatched_length.empty?
    row_nums = rows_with_unmatched_length.map { |row| row[:original_row_num] }.join(', ')
    record.errors.add :csv_file, "All rows must have the same number of cells as the header row. Rows with the wrong length: #{row_nums}"
    false
  end
end
