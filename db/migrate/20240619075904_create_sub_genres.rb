class CreateSubGenres < ActiveRecord::Migration[7.1]
  def change
    create_table :sub_genres do |t|
      t.string :name

      t.timestamps
    end
  end
end
