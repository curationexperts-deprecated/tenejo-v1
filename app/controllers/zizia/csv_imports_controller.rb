# frozen_string_literal: true
module Zizia
  class CsvImportsController < ::ApplicationController
    load_and_authorize_resource
    before_action :load_and_authorize_preview, only: [:preview]
    before_action :antivirus_running?, only: [:new]
    before_action :image_conversion_running?, only: [:new]
    before_action :audiovisual_conversion_running?, only: [:new]

    with_themed_layout 'dashboard'

    def index; end

    def show; end

    def new; end

    # Validate the CSV file and display errors or
    # warnings to the user.
    def preview; end

    def create
      @csv_import.user = current_user
      preserve_cache

      if @csv_import.save
        @csv_import.queue_start_job
        redirect_to @csv_import
      else
        render :new
      end
    end

    private

      def antivirus_running?
        @antivirus_running = list_antivirus_service.present?
      end

      # TODO: Is there a way to make this more service-neutral? Put name of service in configuration?
      def list_antivirus_service
        `ps ax | grep [c]lamd`
      end

      # If MiniMagick can validate a small image, that means it has all its dependencies installed and running.
      def image_conversion_running?
        @image_conversion_running = check_image_conversion
      end

      def check_image_conversion
        image_path = Rails.root.join("spec", "fixtures", "images", "birds.jpg")
        begin
          MiniMagick::Image.open(image_path).validate!
          true
        rescue => error
          Rails.logger.error "There was a problem when testing for MiniMagick: #{error.message} \n"
          false
        end
      end

      def audiovisual_conversion_running?
        @audiovisual_conversion_running = check_audiovisual_conversion.present?
      end

      def check_audiovisual_conversion
        Open3.capture3('ffmpeg -codecs').to_s
      rescue StandardError

        Rails.logger.error('Unable to find ffmpeg')
        ""
      end

      def load_and_authorize_preview
        @csv_import = CsvImport.new(create_params)
        authorize! :create, @csv_import
      end

      def create_params
        params.fetch(:csv_import, {}).permit(:manifest, :fedora_collection_id, :update_actor_stack)
      end

      # Since we are re-rendering the form (once for
      # :new and again for :preview), we need to
      # manually set the cache, otherwise the record
      # will lose the manifest file between the preview
      # and the record save.
      def preserve_cache
        return unless params['csv_import']
        @csv_import.manifest_cache = params['csv_import']['manifest_cache']
        @csv_import.fedora_collection_id = params['csv_import']['fedora_collection_id']
        @csv_import.update_actor_stack = params['csv_import']['update_actor_stack']
      end
  end
end
