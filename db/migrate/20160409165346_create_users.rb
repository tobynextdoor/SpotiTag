class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :spotify_id
      t.string :rspotify_hash
      t.string :tags_string

      t.timestamps null: false
    end
  end
end
