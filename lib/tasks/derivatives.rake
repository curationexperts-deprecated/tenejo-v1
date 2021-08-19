# frozen_string_literal: true
namespace :derivatives do
  desc "Regenerate derivatives for all works"
  task regenerate_all: :environment do
    Hyrax.config.curation_concerns.each do |work_type|
      total = 0

      work_type.all.each do |work|
        regenerate_derivatives(work)
        total += 1
      end

      puts "Regenerated derivatives for #{total} #{work_type} works(s)"
    end
  end

  desc "reprocess a fileset attach "
  task repro_fileset: :environment do
    FileSetAttachedEventJob.new.perform(FileSet.find(ENV.fetch("fsid")), User.find(ENV.fetch("uid")))
  end

  def regenerate_derivatives(work)
    work.file_sets.each do |fs|
      asset_path = fs.original_file.uri.to_s
      asset_path = asset_path[asset_path.index(fs.id.to_s)..-1]
      CreateDerivativesJob.new.perform(fs, asset_path)
    end
  end
end
