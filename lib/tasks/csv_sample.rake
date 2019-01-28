# frozen_string_literal: true
namespace :tenejo do
  desc "Load sample CSV"
  task load_csv_sample: :environment do
    Rake::Task["hyrax:default_admin_set:create"].invoke
    Rake::Task["hyrax:default_collection_types:create"].invoke
    Rake::Task["hyrax:workflow:load"].invoke
    load_csv_sample
  end

  def load_csv_sample
    csv_sample = Rails.root.join('spec', 'fixtures', 'csv_import', 'modular_input.csv')
    ModularImporter.new(csv_sample).import
  end
end
