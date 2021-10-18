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
      add_breadcrumb 'Display options', hyrax.dashboard_path
    end

    def update
      temp_file_path = params["branding"]["banner_image"].path
      redirect_to({ action: :index }, notice: 'Banner image was successfully updated.') if @branding.update(temp_file_path)
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
