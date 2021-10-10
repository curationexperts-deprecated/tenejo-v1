# frozen_string_literal: true
class CsvImport < ApplicationRecord
  has_one_attached :csv_file

  include ActiveModel::Validations
  validates_with CsvImportValidator

  def parsed_csv
    @parsed_csv ||= begin
      original_table = CSV.parse(downloaded_csv, headers: true, header_converters: :symbol)
      original_table.each.with_index(2) do |row, index|
        empty = row.to_hash.values.all?(&:nil?)
        next if empty
        row[:original_row_num] = index
      end
    end
  end

  def downloaded_csv
    @downloaded_csv ||= csv_file.download
  end

  def default_required_headers
    [:title, :creator, :keyword, :rights_statement, :visibility, :files, :deduplication_key]
  end
end
