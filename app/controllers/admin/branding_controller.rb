# frozen_string_literal: true
module Admin
  class BrandingController < ApplicationController
    include Hydra::Controller::ControllerBehavior
    before_action :set_locale
    before_action :ensure_admin!
    with_themed_layout 'dashboard'

    def index
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
    end

  private

    def ensure_admin!
      authorize! :read, :admin_dashboard
    end
  end
end
