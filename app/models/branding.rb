# frozen_string_literal: true

class Branding
  include ActiveModel::Model
  attr_reader :id
  attr_reader :banner_image

  def initialize
    @id = 1
    @banner_image = Hyrax.config.banner_image
  end
end
