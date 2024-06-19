class Track < ApplicationRecord
  belongs_to :album
  belongs_to :media_type
  belongs_to :sub_genre

  has_many :invoice_lines, dependent: :destroy
  has_many :playlist_tracks, dependent: :destroy
  has_many :playlists, through: :playlist_tracks
end
