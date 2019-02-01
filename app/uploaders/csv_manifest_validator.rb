# frozen_string_literal: true

# Validate a CSV file.
#
# Don't put expensive validations in this class.
# This is meant to be used for running a few quick
# validations before starting a CSV-based import.
# It will be called during the HTTP request/response,
# so long-running validations will make the page load
# slowly for the user.  Any validations that are slow
# should be run in background jobs during the import
# instead of here.

class CsvManifestValidator
  # @param manifest_uploader [CsvManifestUploader] The manifest that's mounted to a CsvImport record.  See carrierwave gem documentation.  This is basically a wrapper for the CSV file.
  def initialize(manifest_uploader)
    @csv_file = manifest_uploader.file
    @errors = []
    @warnings = []
  end

  # Errors and warnings for the CSV file.
  attr_reader :errors, :warnings
  attr_reader :csv_file

  def validate
    parse_csv
    return unless @rows

    missing_headers
    unrecognized_headers
    missing_titles
  end

  # One record per row
  def record_count
    return nil unless @rows
    @rows.size - 1 # Don't include the header row
  end

  def valid_headers
    ['title', 'files', 'representative media',
     'thumbnail', 'rendering', 'depositor',
     'date_uploaded', 'date_modified', 'label',
     'relative_path', 'import url', 'resource type',
     'creator', 'contributor', 'abstract or summary',
     'keyword', 'license', 'rights statement',
     'publisher', 'date created', 'subject',
     'language', 'identifier', 'location',
     'related url', 'bibliographic_citation',
     'source', 'visibility']
  end

private

  def parse_csv
    @rows = CSV.read(csv_file.path)
    @headers = @rows.first || []
  rescue
    @errors << 'We are unable to read this CSV file.'
  end

  def missing_headers
    return if @headers.include?('title')
    @errors << 'Missing required column: "title".  Your spreadsheet must have this column.  If you already have this column, please check the spelling and capitalization.'
  end

  # Warn the user if we find any unexpected headers.
  def unrecognized_headers
    extra_headers = @headers - valid_headers
    extra_headers.each do |header|
      @warnings << "The field name \"#{header}\" is not supported.  This field will be ignored, and the metadata for this field will not be imported."
    end
    extra_headers
  end

  def missing_titles
    title_index = @headers.find_index('title')
    return unless title_index

    @rows.each_with_index do |row, i|
      next unless row[title_index].blank?
      @errors << "Missing required metadata \"title\": row #{i}"
    end
  end
end
