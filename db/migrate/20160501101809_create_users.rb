class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :spotify_id
      t.string :name
      t.string :secret

      t.timestamps null: false
    end
  end
end
