class CreateTracks < ActiveRecord::Migration[7.1]
  def change
    create_table :tracks do |t|
      t.string :name
      t.references :album, null: false, foreign_key: true
      t.references :media_type, null: false, foreign_key: true
      t.references :sub_genre, null: false, foreign_key: true
      t.string :composer
      t.integer :milliseconds
      t.integer :bytes
      t.decimal :unit_price

      t.timestamps
    end
  end
end
