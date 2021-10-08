# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CsvImport, type: :model do
  let(:csv_import) { described_class.create(csv_file: csv_upload) }
  let(:csv_upload) { Rack::Test::UploadedFile.new(Rails.root.join(fixture_path, "csv_import", "good", "all_fields.csv")) }

  context "validating a new import" do
    it "uploads a file" do
      expect(csv_import.csv_file).to be_an_instance_of(ActiveStorage::Attached::One)
      expect(csv_import.csv_file.attached?).to be true
      expect(csv_import.csv_file.content_type).to eq "text/plain"
      expect(csv_import.valid?).to be true
    end
    context "with invalid files" do
      context "an empty import" do
        let(:csv_import) { described_class.create(csv_file: nil) }

        it "does not validate the import" do
          expect(csv_import.valid?).to be false
          expect(csv_import.errors.messages[:csv_file]).to include("Must attach a file")
        end
      end

      context "with a file other than a csv" do
        let(:csv_upload) { Rack::Test::UploadedFile.new(Rails.root.join(fixture_path, 'images', 'birds.jpg')) }

        it "does not validate the import" do
          expect(csv_import.valid?).to be false
          expect(csv_import.errors.messages[:csv_file]).to include("Must be a csv file, your file has been determined to be: image/jpeg")
        end
      end

      context "with a file pretending to be a csv" do
        let(:csv_upload) { Rack::Test::UploadedFile.new(Rails.root.join(fixture_path, "csv_import", "csv_files_with_problems", "not_a_csv_file.pdf.csv")) }

        it "does not validate the import" do
          expect(csv_import.valid?).to be false
          expect(csv_import.errors.messages[:csv_file]).to include("Must be a csv file, your file has been determined to be: application/pdf")
        end
      end

      context "missing required headers" do
        let(:csv_upload) { Rack::Test::UploadedFile.new(Rails.root.join(fixture_path, "csv_import", "csv_files_with_problems", "missing_headers.csv")) }

        it "does not validate the import" do
          expect(csv_import.valid?).to be false
          expect(csv_import.errors.messages[:csv_file])
            .to match_array(['The file is missing required headers. Missing headers are: title, creator, keyword, rights_statement, visibility, files, deduplication_key'])
        end
      end

      context "just headers" do
        let(:csv_upload) { Rack::Test::UploadedFile.new(Rails.root.join(fixture_path, "csv_import", "csv_files_with_problems", "just_headers.csv")) }

        it "does not validate the import" do
          expect(csv_import.valid?).to be false
          expect(csv_import.errors.messages[:csv_file])
            .to include('The file has no rows with data')
        end
      end

      context "just empty rows" do
        let(:csv_upload) { Rack::Test::UploadedFile.new(Rails.root.join(fixture_path, "csv_import", "csv_files_with_problems", "just_headers_and_empty_rows.csv")) }

        it "does not validate the import" do
          expect(csv_import.valid?).to be false
          expect(csv_import.errors.messages[:csv_file])
            .to include('The file has no rows with data')
        end
      end

      context "duplicate headers" do
        let(:csv_upload) { Rack::Test::UploadedFile.new(Rails.root.join(fixture_path, "csv_import", "csv_files_with_problems", "duplicate_headers.csv")) }

        it "does not validate the import" do
          expect(csv_import.valid?).to be false
          expect(csv_import.errors.messages[:csv_file])
            .to include('The file has duplicate headers. Duplicate headers are: title, keyword, creator')
        end
      end
    end
  end
end
