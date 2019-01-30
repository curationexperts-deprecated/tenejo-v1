# frozen_string_literal: true

class CsvImport < ApplicationRecord
  belongs_to :user

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
end
