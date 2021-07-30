# frozen_string_literal: true
namespace :tenejo do
  desc "fix collection type translations"
  task fix_i18n: :environment do
    Hyrax::CollectionType.all.find_all { |x| x.title =~ /translation missing/ }.each do |x|
      # strip off error message & locale to get key
      translation = I18n.t(x.title.split.last.split(".")[1..].join('.'))
      x.update!(title: translation)
    end
  end

  desc "move default banner image if new one hasn't been uploaded"
  task move_banner_image: :environment do
    public_asset_path = Rails.root.join("public", "assets", "banner_image.jpg")
    app_asset_path = Rails.root.join("app", "assets", "images", "banner_image.jpg")
    FileUtils.cp(app_asset_path, public_asset_path) unless File.exist?(public_asset_path)
  end

  desc "Setup standard login accounts"
  task standard_users_setup: :environment do
    create_first_admin_user
  end

  desc "Cleanup all uploaded files and delete all user accounts"
  task clean: :environment do
    Hyrax::UploadedFile.all.each(&:destroy!)
    Work.all.each(&:destroy!)
    Collection.all.each(&:destroy!)
    Zizia::CsvImport.all.each(&:destroy!)
    User.all.each(&:destroy!)
  end

  def create_first_admin_user
    u = User.find_or_create_by(email: ENV['ADMIN_EMAIL'])
    u.display_name = ENV['ADMIN_DISPLAY_NAME']
    u.password = ENV['ADMIN_PASSWORD']
    u.save
    assign_admin_role_to_first_admin(u) unless u.admin?
  end

  def assign_admin_role_to_first_admin(user)
    admin_role = Role.find_or_create_by(name: 'admin')
    admin_role.users << user
    admin_role.save
  end
end
