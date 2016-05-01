class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :song_id
      t.integer :user_id
      t.integer :tag_id

      t.timestamps null: false
    end
  end
end
