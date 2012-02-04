class AddRefreshtoTweets < ActiveRecord::Migration
  def up
    add_column :tweetloads, :refresh, :boolean
  end

  def down
    remove_column :tweetloads, :refresh
  end
end
