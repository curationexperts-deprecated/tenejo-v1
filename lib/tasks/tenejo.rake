# frozen_string_literal: true
namespace :tenejo do
  desc "Setup standard login accounts"
  task standard_users_setup: :environment do
    create_first_user
    create_first_admin_user
  end

  desc "Cleanup all uploaded files and delete all user accounts"
  task clean: :environment do
    Hyrax::UploadedFile.all.each(&:destroy!)
    Work.all.each(&:destroy!)
    Collection.all.each(&:destroy!)
    User.all.each(&:destroy!)
  end

  def create_first_user
    u = User.find_or_create_by(email: ENV['FIRST_USER_EMAIL'])
    u.display_name = ENV['FIRST_USER_DISPLAY_NAME']
    u.password = ENV['FIRST_USER_PASSWORD']
    u.save
  end

  def create_first_admin_user
    u = User.find_or_create_by(email: ENV['ADMIN_EMAIL'])
    u.display_name = ENV['ADMIN_DISPLAY_NAME']
    u.password = ENV['ADMIN_PASSWORD']
    u.save
    admin_role = Role.find_or_create_by(name: 'admin')
    admin_role.users << u
    admin_role.save
  end
end
