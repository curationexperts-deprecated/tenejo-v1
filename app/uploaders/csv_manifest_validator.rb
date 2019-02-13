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
    duplicate_headers
    unrecognized_headers
    missing_titles
    invalid_license
    invalid_resource_type
    invalid_rights_statement
  end

  # One record per row
  def record_count
    return nil unless @rows
    @rows.size - 1 # Don't include the header row
  end

  def delimiter
    @delimiter ||= default_delimiter
  end
  attr_writer :delimiter

private

  def default_delimiter
    Darlingtonia::HyraxBasicMetadataMapper.new.delimiter
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
    @active_ids ||= Hyrax::LicenseService.new.authority.all.select { |license| license[:active] }.map { |license| license[:id] }
  end

  def parse_csv
    @rows = CSV.read(csv_file.path)
    @headers = @rows.first || []
    @transformed_headers = @headers.map { |header| header.downcase.strip }
  rescue
    @errors << 'We are unable to read this CSV file.'
  end

  def missing_headers
    required_headers.each do |header|
      next if @transformed_headers.include?(header)
      @errors << "Missing required column: \"#{header.titleize}\".  Your spreadsheet must have this column."
    end
  end

  def required_headers
    ['title', 'creator', 'keyword', 'rights statement', 'visibility', 'files']
  end

  def duplicate_headers
    duplicates = []
    sorted_headers = @transformed_headers.sort
    sorted_headers.each_with_index do |x, i|
      duplicates << x if x == sorted_headers[i + 1]
    end
    duplicates.uniq.each do |header|
      @errors << "Duplicate column names: You can have only one \"#{header.titleize}\" column."
    end
  end

  # We can only allow valid license values expected by Hyrax. Otherwise, the application
  # throws an error when it tries to display the work.
  def invalid_license
    license_index = @transformed_headers.find_index('license')
    return unless license_index

    @rows.each_with_index do |row, i|
      next if i.zero? # Skip the header row
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

  def invalid_resource_type
    rt_index = @transformed_headers.find_index('resource type')
    return unless rt_index

    @rows.each_with_index do |row, i|
      next if i.zero? # Skip the header row
      next unless row[rt_index]

      values = row[rt_index].split(delimiter)
      invalid_rt = values.select { |rt| !valid_resource_types.include?(rt) }

      invalid_rt.each do |rt|
        @errors << "Invalid Resource Type in row #{i}: #{rt}"
      end
    end
  end

  def valid_resource_types
    @valid_resource_type_ids ||= Qa::Authorities::Local.subauthority_for('resource_types').all.select { |term| term[:active] }.map { |term| term[:id] }
  end

  def invalid_rights_statement
    index = @transformed_headers.find_index('rights statement')
    return unless index

    @rows.each_with_index do |row, i|
      next if i.zero? # Skip the header row
      next unless row[index]

      values = row[index].split(delimiter)
      invalid_values = values.select { |value| !valid_rights_statements.include?(value) }

      invalid_values.each do |value|
        @errors << "Invalid Rights Statement in row #{i}: #{value}"
      end
    end
  end

  def valid_rights_statements
    @valid_rights_statement_ids ||= Qa::Authorities::Local.subauthority_for('rights_statements').all.select { |term| term[:active] }.map { |term| term[:id] }
  end
end
