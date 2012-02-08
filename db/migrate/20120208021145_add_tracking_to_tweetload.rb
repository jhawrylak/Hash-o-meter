class AddTrackingToTweetload < ActiveRecord::Migration
  def change
    add_column :tweetloads, :tracking, :string
  end
end
