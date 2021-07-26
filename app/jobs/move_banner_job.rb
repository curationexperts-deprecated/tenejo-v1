# frozen_string_literal: true
class MoveBannerJob < ApplicationJob
  queue_as :default

  def default_priority
    -100
  end

  def perform(*_args)
    public_asset_path = Rails.root.join("public", "assets", "banner_image.jpg")
    app_asset_path = Rails.root.join("app", "assets", "images", "banner_image.jpg")
    FileUtils.cp(app_asset_path, public_asset_path) unless File.exist?(public_asset_path)
  end
end
