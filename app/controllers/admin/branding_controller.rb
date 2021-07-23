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
      new_file_path = File.join(Rails.root, "public/assets", "banner_image.jpg")
      orig_file_path = "app/assets/images/banner_image.jpg"
      FileUtils.mkdir_p(File.join(Rails.root, "public/assets"))
      FileUtils.cp(temp_file_path, new_file_path)
      FileUtils.rm(temp_file_path)
      FileUtils.chmod(0644, new_file_path)
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
