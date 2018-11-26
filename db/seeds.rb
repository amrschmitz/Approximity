# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
puts "destroying Db"
Business.destroy_all

require "byebug"


parameters = "key=#{ENV['API_PLACES_KEY']}"
bakery = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=bakery+in+montreal&#{parameters}"
shoemaker = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=shoemaker+in+montreal&#{parameters}"
butcher = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=butcher+in+montreal&#{parameters}"
drycleaner = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=dry+cleaner+in+montreal&#{parameters}"

ids = []

bakery_serialized = open(bakery).read
bakeryid = JSON.parse(bakery_serialized)

shoemaker_serialized = open(shoemaker).read
shoemakerid = JSON.parse(shoemaker_serialized)

butcher_serialized = open(butcher).read
butcherid = JSON.parse(butcher_serialized)

drycleaner_serialized = open(drycleaner).read
drycleanerid = JSON.parse(drycleaner_serialized)


(bakeryid["results"] + shoemakerid["results"] + butcherid["results"] + drycleanerid["results"]).each do |result|
 ids << result["place_id"]
end

ids.each do |id|
  details_url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=#{id}&#{parameters}"
  details_serialized = open(details_url).read
  details = JSON.parse(details_serialized)["result"]
  photosarray = details["photos"]

  photo_url = nil

  begin
  # Try to find a good photo
  photosarray.each do |foto|
    if foto["html_attributions"].first.include?(details["name"])
      fotoref = foto["photo_reference"]
      photo_url = open("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=#{fotoref}&#{parameters}").base_uri.to_s
    end
  end

  # If you cannot, take the first one
  if photo_url.nil?
    fotoref = photosarray.first["photo_reference"]
    photo_url = open("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=#{fotoref}&#{parameters}").base_uri.to_s
  end

    name = details["name"]
    shortaddress = details["vicinity"]
    longaddress = details["formatted_address"]
    phone = details["formatted_phone_number"]
    ratings = details["rating"]
    hours = details["opening_hours"]["weekday_text"]
    category = details["types"][0]
    website = details["website"]
    price_level = details["price_level"]
    latitude = details["geometry"]["location"]["lat"]
    longitude = details["geometry"]["location"]["lng"]

    business = Business.create!(
      name: name,
      shortaddress: shortaddress,
      longaddress: longaddress,
      phone: phone,
      ratings: ratings,
      hours: hours,
      category: category,
      website: website,
      price_level: price_level,
      latitude: latitude,
      longitude: longitude,
      photo: photo_url,
      )

    three_reviews = details["reviews"]
    three_reviews.first(5).each do |review|
      rating = review["rating"]
      text = review["text"]
      name = review["author_name"]
      Review.create!(rating: rating,
                     business: business,
                     content: text,
                     author_name: name,
                     )
    end
  rescue NoMethodError
    puts "missing data"
  end
end

# Business.find_by(name: "").update(photo: "")

# https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CmRaAAAAHBB9g9c1CJ7ULV2pfppJUrlWDW45UT7L_3bgUuAyU8d0nUYSdx69Fv3vpk_As4Hyp4ieOSMvwJY_sGupaQKNogl1Gr_kujKO014I8Zs_BGFtNt7vtedr3feyNGUEX_48EhAcsTjnA_wgmkgRJwhNbxDiGhQ6aFYk4_-OkPB5ssd7DWzAGzX6Gg&key=AIzaSyDMqN5rmD_oqC4eIOlYxBKA_JdTEpk2fAc



# storedb = []

# puts "#{store['place_id']}"
#faire une requete generale par localisation
# response['candidates'] est un array
# array_of_ids = response['candidates'].map { |business| business['id']}

# array_of_ids.each do |id|
  # faire une requete detail pour chaque id
  # Business.create(...)
# end

