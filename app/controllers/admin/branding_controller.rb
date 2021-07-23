# frozen_string_literal: true
module Admin
  class BrandingController < ApplicationController
    include Hydra::Controller::ControllerBehavior
    before_action :set_locale
    before_action :ensure_admin!
    before_action :set_branding
    with_themed_layout 'dashboard'

    def index
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    end

    def edit
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    end

    def update
      temp_file_path = params["branding"]["banner_image"].path
      assets_path = Rails.root.join("public", "assets")
      orig_file_path = File.join(assets_path, "banner_image.jpg")
      # Move the original banner image to _old
      FileUtils.mv(orig_file_path, File.join(assets_path, "banner_image_old.jpg"))
      # Move the uploaded banner image to banner_image.jpg
      FileUtils.cp(temp_file_path, orig_file_path)
      # Get rid of the tempfile
      FileUtils.rm(temp_file_path)
      # rubocop:disable Style/NumericLiteralPrefix
      FileUtils.chmod(0644, orig_file_path)
      # rubocop:enable Style/NumericLiteralPrefix
      # if @branding.update(temp_file_path)
      redirect_to({ action: :index }, notice: 'Banner image was successfully updated.')
      # end
    end

  private

    def ensure_admin!
      authorize! :read, :admin_dashboard
    end

    def set_branding
      @branding = Branding.new
    end
  end
end
