class MoveBannerImage < ActiveRecord::Migration[5.2]
  def change
    MoveBannerJob.perform_later
  end
end
