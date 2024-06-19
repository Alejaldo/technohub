class CreatePlaylistTracks < ActiveRecord::Migration[7.1]
  def change
    create_table :playlist_tracks do |t|
      t.references :playlist, null: false, foreign_key: true
      t.references :track, null: false, foreign_key: true

      t.timestamps
    end

    add_index :playlist_tracks, [:playlist_id, :track_id], unique: true
  end
end
