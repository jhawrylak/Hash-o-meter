class CreateTweetloads < ActiveRecord::Migration
  def change
    create_table :tweetloads do |t|
      t.integer :process
      t.timestamps
    end
  end
end
