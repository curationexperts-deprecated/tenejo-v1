# frozen_string_literal: true

class CsvImport < ApplicationRecord
  belongs_to :user

  # This is where the CSV file is stored:
  mount_uploader :manifest, CsvManifestUploader

  def manifest_warnings
    manifest.warnings
  end

  def manifest_errors
    manifest.errors
  end

  def manifest_records
    manifest.records
  end

  def queue_start_job
    StartCsvImportJob.perform_later(id)
    # TODO: We'll probably need to store job_id on this record.
  end
end
