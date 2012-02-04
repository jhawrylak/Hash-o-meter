class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :text
      t.string :user
      t.datetime :time
      t.string :filter

      t.timestamps
    end
  end
end
