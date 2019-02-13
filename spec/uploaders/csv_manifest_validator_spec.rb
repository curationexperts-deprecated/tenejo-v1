# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CsvManifestValidator, type: :model do
  let(:validator) { described_class.new(manifest) }
  let(:manifest) { csv_import.manifest }
  let(:user) { FactoryBot.build(:user) }
  let(:csv_import) do
    import = CsvImport.new(user: user)
    File.open(csv_file) { |f| import.manifest = f }
    import
  end

  context 'delimiter' do
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'import_manifest.csv') }

    it 'can set a different delimiter' do
      expect(validator.delimiter).to eq '|~|'
      validator.delimiter = 'ಠ_ಠ'
      expect(validator.delimiter).to eq 'ಠ_ಠ'
    end
  end

  context 'a valid CSV file' do
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'import_manifest.csv') }

    before { validator.validate }

    it 'has no errors' do
      expect(validator.errors).to eq []
    end

    it 'has no warnings' do
      expect(validator.warnings).to eq []
    end

    it 'returns the record count' do
      expect(validator.record_count).to eq 3
    end
  end

  context 'a valid CSV file with capitalization and whitespace in headers' do
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'modular_input.csv') }

    before { validator.validate }

    it 'has no errors' do
      expect(validator.errors).to eq []
    end

    it 'has no warnings' do
      expect(validator.warnings).to eq []
    end

    it 'returns the record count' do
      expect(validator.record_count).to eq 3
    end
  end

  context 'a file that can\'t be parsed' do
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'not_a_csv_file.pdf.csv') }

    it 'has an error' do
      validator.validate
      expect(validator.errors).to eq ['We are unable to read this CSV file.']
    end
  end

  context 'a CSV that is missing required headers' do
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'missing_headers.csv') }

    it 'has an error' do
      validator.validate
      expect(validator.errors).to eq [
        'Missing required column: "Title".  Your spreadsheet must have this column.',
        'Missing required column: "Creator".  Your spreadsheet must have this column.',
        'Missing required column: "Keyword".  Your spreadsheet must have this column.',
        'Missing required column: "Rights Statement".  Your spreadsheet must have this column.',
        'Missing required column: "Visibility".  Your spreadsheet must have this column.',
        'Missing required column: "Files".  Your spreadsheet must have this column.'
      ]
    end
  end

  context 'a CSV that is missing required fields' do
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'missing_title_field.csv') }

    it 'has an error' do
      validator.validate
      expect(validator.errors).to eq [
        'Missing required metadata "Title": row 2',
        'Missing required metadata "Title": row 3',
        'Missing required metadata "Title": row 5'
      ]
    end
  end

  context 'a CSV that has extra headers' do
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'extra - headers.csv') }

    it 'has a warning' do
      validator.validate
      expect(validator.warnings).to eq [
        'The field name "rights_statement" is not supported.  This field will be ignored, and the metadata for this field will not be imported.',
        'The field name "another_header_2" is not supported.  This field will be ignored, and the metadata for this field will not be imported.'
      ]
    end
  end

  context 'a CSV that has invalid license values' do
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'errors', 'invalid_license.csv') }

    it 'has an error' do
      validator.validate
      expect(validator.errors).to eq [
        "Invalid License in row 2: http://creativecommons.org/licenses/foobar"
      ]
    end
  end

  context 'a CSV with invalid resource type' do
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'invalid_resource_type.csv') }

    it 'has errors' do
      validator.validate
      expect(validator.errors).to eq [
        'Invalid Resource Type in row 2: An Invalid Type',
        'Invalid Resource Type in row 4: Another Resource Type'
      ]
    end
  end

  context 'a CSV with duplicate headers' do
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'duplicate_headers.csv') }

    it 'has errors' do
      validator.validate
      expect(validator.errors).to eq [
        'Duplicate column names: You can have only one "Creator" column.',
        'Duplicate column names: You can have only one "Keyword" column.',
        'Duplicate column names: You can have only one "Title" column.'
      ]
    end
  end

  context 'a CSV with invalid rights statements' do
    let(:csv_file) { File.join(fixture_path, 'csv_import', 'csv_files_with_problems', 'invalid_rights.csv') }

    it 'has errors' do
      validator.validate
      expect(validator.errors).to eq [
        'Invalid Rights Statement in row 3: something_invalid',
        'Invalid Rights Statement in row 4: invalid rights statement'
      ]
    end
  end
end
