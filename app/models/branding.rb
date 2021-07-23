# frozen_string_literal: true

class Branding
  include ActiveModel::Model
  attr_reader :id
  attr_reader :banner_image

  def initialize
    @id = 1
    @banner_image = 'assets/banner_image.jpg'
  end

  def update(temp_file_path)
    assets_path = Rails.root.join("public", "assets")
    orig_file_path = File.join(assets_path, "banner_image.jpg")
    # Move the original banner image to _old
    FileUtils.mv(orig_file_path, File.join(assets_path, "banner_image_old.jpg")) if File.exist?(orig_file_path)
    # Move the uploaded banner image to banner_image.jpg
    FileUtils.cp(temp_file_path, orig_file_path)
    # Get rid of the tempfile
    FileUtils.rm(temp_file_path)
    # rubocop:disable Style/NumericLiteralPrefix
    FileUtils.chmod(0644, orig_file_path)
    # rubocop:enable Style/NumericLiteralPrefix
  end
end
