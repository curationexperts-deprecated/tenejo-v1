# frozen_string_literal: true

module ServicesHelper
  def services
    ["antivirus", "image conversion", "media processing", "background processing", "file characterization"]
  end

  def service_running?(service)
    case service
    when "antivirus"
      check_antivirus_service
    when "image conversion"
      check_image_conversion
    when "media processing"
      check_audiovisual_conversion
    when "background processing"
      check_background_processing
    when "file characterization"
      check_characterization
    end
  end

  def check_background_processing
    check_sidekiq && check_redis
  end

  def check_sidekiq
    stdout_str, _stderr_str, _status = Open3.capture3('ps aux | grep [s]idekiq')
    if stdout_str.present?
      true
    else
      false
    end
  rescue => error
    Rails.logger.error "There was a problem when testing for Sidekiq: #{error.message} \n"
    false
  end

  def check_redis
    Redis.current.ping
    true
  rescue => error
    Rails.logger.error "There was a problem when testing for Redis: #{error.message} \n"
    false
  end

  def check_antivirus_service
    image_path = Rails.root.join("spec", "fixtures", "images", "birds.jpg")
    begin
      Clamby.safe?(image_path.to_s)
    rescue => error
      Rails.logger.error "There was a problem when testing for Clamby / ClamAV: #{error.message} \n"
      false
    end
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

  def check_audiovisual_conversion
    Open3.capture3('ffmpeg -codecs')
    true
  rescue StandardError
    Rails.logger.error('Unable to find ffmpeg')
    false
  end

  def check_characterization
    false
  end
end
