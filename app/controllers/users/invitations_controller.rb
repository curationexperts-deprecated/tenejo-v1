# frozen_string_literal: true

class Users::InvitationsController < Devise::InvitationsController
  before_action :ensure_admin!, only: [:new, :create]

  private

  def ensure_admin!
    authorize! :read, :admin_dashboard
  end
end
