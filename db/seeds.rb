# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

# Clear existing data in the correct order
puts "Clearing existing data..."
PlaylistTrack.destroy_all
InvoiceLine.destroy_all
Invoice.destroy_all
Customer.destroy_all
Employee.destroy_all
Track.destroy_all
Album.destroy_all
Artist.destroy_all
MediaType.destroy_all
SubGenre.destroy_all
Playlist.destroy_all
puts "Data cleared."

# Seeding SubGenres
puts "Seeding SubGenres..."
sub_genres = [
  "Acid Techno", "Ambient Techno", "Bleep Techno", "Breakbeat Techno",
  "Dark Techno", "Deep Techno", "Detroit Techno", "Dub Techno",
  "Electro Techno", "Ethereal Techno", "Hard Techno", "Hypnotic Techno",
  "Industrial Techno", "Melodic Techno", "Minimal Techno", "Peak Time Techno",
  "Progressive Techno", "Schranz", "Tribal Techno"
]

sub_genres.each do |name|
  SubGenre.find_or_create_by(name: name)
end
puts "SubGenres seeded."

# Seeding MediaTypes
puts "Seeding MediaTypes..."
media_types = ["MP3", "WAV", "FLAC", "AAC", "OGG"]

media_types.each do |name|
  MediaType.find_or_create_by(name: name)
end
puts "MediaTypes seeded."

# Seeding Artists and Albums
puts "Seeding Artists and Albums..."
100.times do |i|
  artist = Artist.create(name: Faker::Music.band)
  puts "Seeded artist #{i + 1} / 100" if (i + 1) % 10 == 0

  5.times do |j|
    album = Album.create(title: Faker::Music.album, artist: artist)
    puts "  Seeded album #{j + 1} / 50 for artist #{i + 1}" if (j + 1) % 10 == 0

    # Seeding Tracks
    100.times do |k|
      Track.create(
        name: Faker::Music::RockBand.song,
        album: album,
        media_type: MediaType.all.sample,
        sub_genre: SubGenre.all.sample,
        composer: Faker::Name.name,
        milliseconds: Faker::Number.between(from: 200000, to: 600000),
        bytes: Faker::Number.between(from: 1000000, to: 10000000),
        unit_price: Faker::Commerce.price(range: 0.5..1.5)
      )
      puts "    Seeded track #{k + 1} / 1000 for album #{j + 1}" if (k + 1) % 100 == 0
    end
  end
end
puts "Artists and Albums seeded."

# Seeding Customers
puts "Seeding Customers..."
2000.times do |i|
  Customer.create(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    company: Faker::Company.name,
    address: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state,
    country: Faker::Address.country,
    postal_code: Faker::Address.zip,
    phone: Faker::PhoneNumber.phone_number,
    fax: Faker::PhoneNumber.phone_number,
    email: Faker::Internet.email,
    support_rep: Employee.all.sample
  )
  puts "Seeded customer #{i + 1} / 2000" if (i + 1) % 200 == 0
end
puts "Customers seeded."

# Seeding Employees
puts "Seeding Employees..."
50.times do |i|
  Employee.create(
    last_name: Faker::Name.last_name,
    first_name: Faker::Name.first_name,
    title: Faker::Job.title,
    birth_date: Faker::Date.birthday(min_age: 20, max_age: 60),
    hire_date: Faker::Date.backward(days: 3650),
    address: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state,
    country: Faker::Address.country,
    postal_code: Faker::Address.zip,
    phone: Faker::PhoneNumber.phone_number,
    fax: Faker::PhoneNumber.phone_number,
    email: Faker::Internet.email,
    manager: Employee.all.sample
  )
  puts "Seeded employee #{i + 1} / 50" if (i + 1) % 10 == 0
end
puts "Employees seeded."

# Seeding Invoices
puts "Seeding Invoices..."
Customer.all.each_with_index do |customer, i|
  rand(1..5).times do |j|
    invoice = Invoice.create(
      customer: customer,
      invoice_date: Faker::Date.backward(days: 365),
      billing_address: customer.address,
      billing_city: customer.city,
      billing_state: customer.state,
      billing_country: customer.country,
      billing_postal_code: customer.postal_code,
      total: Faker::Commerce.price(range: 10..100)
    )

    # Seeding InvoiceLines
    Track.all.sample(rand(1..5)).each do |track|
      InvoiceLine.create(
        invoice: invoice,
        track: track,
        unit_price: track.unit_price,
        quantity: rand(1..3)
      )
    end
  end
  puts "Seeded invoices for customer #{i + 1} / #{Customer.count}" if (i + 1) % 200 == 0
end
puts "Invoices seeded."

# Seeding Playlists and PlaylistTracks
puts "Seeding Playlists and PlaylistTracks..."
100.times do |i|
  playlist = Playlist.create(name: Faker::Music.genre)

  Track.all.sample(rand(10..30)).each do |track|
    # Ensure no duplicates
    PlaylistTrack.find_or_create_by(playlist: playlist, track: track)
  end
  puts "Seeded playlist #{i + 1} / 100" if (i + 1) % 10 == 0
end
puts "Playlists and PlaylistTracks seeded."

puts "Seeding completed."
