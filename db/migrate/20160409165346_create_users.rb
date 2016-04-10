class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :spotify_id
      t.text :rspotify_hash

      t.string :secret

      t.text :tags_string

      t.timestamps null: false
    end
  end
end
