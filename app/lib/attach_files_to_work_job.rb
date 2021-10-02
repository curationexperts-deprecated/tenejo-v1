# frozen_string_literal: true

##
# Class copied from Hyrax at 52380581f27da9af65fc44b76c1ab837aea815a0.
#
# Converts UploadedFiles into FileSets and attaches them to works.
class AttachFilesToWorkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  # @param [ActiveFedora::Base] work - the work object
  # @param [Array<Hyrax::UploadedFile>] uploaded_files - an array of files to attach
  def perform(work, uploaded_files, **work_attributes)
    validate_files!(uploaded_files)
    depositor = proxy_or_depositor(work)
    user = User.find_by_user_key(depositor)
    work_permissions = work.permissions.map(&:to_hash)
    metadata = visibility_attributes(work_attributes)
    uploaded_files.each do |uploaded_file|
      next if uploaded_file.file_set_uri.present?

      virus_check!(uploaded_file, user)
      actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user)
      uploaded_file.update(file_set_uri: actor.file_set.uri)
      actor.file_set.permissions_attributes = work_permissions
      actor.create_metadata(metadata)
      actor.create_content(uploaded_file)
      actor.attach_to_work(work)
    end
  rescue VirusDetectedError => error
    Rails.logger.error "A virus was detected when uploading a file for work #{work.id}: #{error.message} \n"
  end
  # rubocop:enable Metrics/MethodLength

  class VirusDetectedError < RuntimeError; end

  private

  def virus_check!(uploaded_file, user)
    return unless Hydra::Works::VirusCheckerService.file_has_virus?(uploaded_file.file)
    carrierwave_file = uploaded_file.file.file
    carrierwave_file.delete
    user.send_message(user, "A virus was detected while uploading files it has been deleted and a log was created.",
                      "Virus encountered while processing the file #{carrierwave_file.filename} uploaded by #{user.email}")
    Rails.logger.error "Virus encountered while processing file #{carrierwave_file.filename} uploaded by #{user.email}.\n"
    raise(VirusDetectedError, carrierwave_file.filename)
  end

  # The attributes used for visibility - sent as initial params to created FileSets.
  def visibility_attributes(attributes)
    attributes.slice(:visibility, :visibility_during_lease,
                     :visibility_after_lease, :lease_expiration_date,
                     :embargo_release_date, :visibility_during_embargo,
                     :visibility_after_embargo)
  end

  def validate_files!(uploaded_files)
    uploaded_files.each do |uploaded_file|
      next if uploaded_file.is_a? Hyrax::UploadedFile
      raise ArgumentError, "Hyrax::UploadedFile required, but #{uploaded_file.class} received: #{uploaded_file.inspect}"
    end
  end

  ##
  # A work with files attached by a proxy user will set the depositor as the intended user
  # that the proxy was depositing on behalf of. See tickets #2764, #2902.
  def proxy_or_depositor(work)
    work.on_behalf_of.presence || work.depositor
  end
end
