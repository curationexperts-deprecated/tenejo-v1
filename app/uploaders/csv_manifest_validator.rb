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
    invalid_license
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

  def valid_licenses
    [
      'http://creativecommons.org/licenses/by/3.0/us/',
      'http://creativecommons.org/licenses/by-sa/3.0/us/',
      'http://creativecommons.org/licenses/by-nc/3.0/us/',
      'http://creativecommons.org/licenses/by-nd/3.0/us/',
      'http://creativecommons.org/licenses/by-nc-nd/3.0/us/',
      'http://creativecommons.org/licenses/by-nc-sa/3.0/us/',
      'http://www.europeana.eu/portal/rights/rr-r.html',
      'https://creativecommons.org/licenses/by/4.0/',
      'https://creativecommons.org/licenses/by-sa/4.0/',
      'https://creativecommons.org/licenses/by-nd/4.0/',
      'https://creativecommons.org/licenses/by-nc/4.0/',
      'https://creativecommons.org/licenses/by-nc-nd/4.0/',
      'https://creativecommons.org/licenses/by-nc-sa/4.0/',
      'http://creativecommons.org/publicdomain/zero/1.0/',
      'http://creativecommons.org/publicdomain/mark/1.0/'
    ]
  end

private

  def parse_csv
    @rows = CSV.read(csv_file.path)
    @headers = @rows.first || []
    @transformed_headers = @headers.map { |header| header.downcase.strip }
  rescue
    @errors << 'We are unable to read this CSV file.'
  end

  def missing_headers
    return if @transformed_headers.include?('title')
    @errors << 'Missing required column: "title".  Your spreadsheet must have this column.  If you already have this column, please check the spelling.'
  end

  # We can only allow valid license values expected by Hyrax. Otherwise, the application
  # throws an error when it tries to display the work.
  def invalid_license
    license_index = @transformed_headers.find_index('license')
    return unless license_index

    @rows.each_with_index do |row, i|
      next if row[license_index] == 'license' # Skip the header row
      next if row[license_index].nil?
      next if valid_licenses.include?(row[license_index])
      @errors << "Invalid license value in row #{i}: #{row[license_index]}"
    end
  end

  # Warn the user if we find any unexpected headers.
  def unrecognized_headers
    extra_headers = @transformed_headers - valid_headers
    extra_headers.each do |header|
      @warnings << "The field name \"#{header}\" is not supported.  This field will be ignored, and the metadata for this field will not be imported."
    end
  end

  def missing_titles
    title_index = @transformed_headers.find_index('title')
    return unless title_index

    @rows.each_with_index do |row, i|
      next unless row[title_index].blank?
      @errors << "Missing required metadata \"Title\": row #{i}"
    end
  end
end
