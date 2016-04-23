class Place
  include ActiveModel::Model
  attr_accessor :id, :formatted_address, :location, :address_components

  MONGO_URL = 'mongodb://localhost:27017'
  MONGO_DATABASE = 'ruby-labs'
  PLACE_COLLECTION = 'places'
  LOCATION_INDEX_NAME = 'geometry.geolocation_2dsphere'

  @@db = nil

  # helper function to obtain connection to server and set connection to use specific DB
  # set environment variables MONGO_URL and MONGO_DATABASE to alternate values if not
  # using the default.
  def self.mongo_client
    url = ENV['MONGO_URL'] ||= MONGO_URL
    database = ENV['MONGO_DATABASE'] ||= MONGO_DATABASE
    db = Mongo::Client.new(url)
    @@db = db.use(database)
  end

  # helper method to obtain collection used to make race results. set environment
  # variable RACE_COLLECTION to alternate value if not using the default.
  def self.collection
    collection = ENV['PLACE_COLLECTION'] ||= PLACE_COLLECTION
    mongo_client if @@db.nil?
    @@db[collection]
  end

  # loads a JSON document with places information into the places collection.
  def self.load_all(io)
    data = JSON.parse(io.read)
    collection.insert_many data
  end

  def self.find_by_short_name(short_name)
    collection.find('address_components.short_name' => short_name)
  end

  def self.to_places(places_collection)
    places_collection.map do |place|
      Place.new(place)
    end
  end

  def self.find(id)
    hash = collection.find(_id: BSON::ObjectId.from_string(id)).first
    Place.new(hash) unless hash.nil?
  end

  def self.all(offset = 0, limit = nil)
    result = collection.find.skip(offset)
    result = result.limit(limit) unless limit.nil?
    to_places(result)
  end

  def self.get_address_components(sort = nil, offset = nil, limit = nil)
    aggregate = [
      {:$unwind => '$address_components'},
      {:$project => {:address_components => 1, :formatted_address => 1, :geometry => {:geolocation => 1}}}]
    aggregate << {:$sort => sort} unless sort.nil?
    aggregate << {:$skip => offset} unless offset.nil?
    aggregate << {:$limit => limit} unless limit.nil?
    collection.find.aggregate(aggregate)
  end

  def self.get_country_names
    collection.aggregate([
      {:$unwind => '$address_components'},
      {:$match => {'address_components.types' => 'country'}},
      {:$group => {_id: 0, country_names: {:$addToSet => '$address_components.long_name'}}}
      ]).first[:country_names]
  end

  def self.find_ids_by_country_code(country_code)
    collection.aggregate([
      {:$match => {'address_components.types' => 'country', 'address_components.short_name' => country_code}},
      {:$project => {_id: 1}}
      ]).map {|doc| doc[:_id].to_s}
  end

  def self.create_indexes
    collection.indexes.create_one(
      {'geometry.geolocation' => Mongo::Index::GEO2DSPHERE},
      {name: LOCATION_INDEX_NAME})
  end

  def self.remove_indexes
    collection.indexes.drop_one LOCATION_INDEX_NAME
  end

  def self.near(point, max_meters = nil)
    collection.find(
        'geometry.geolocation' => {:$near => {
            :$geometry => point.to_hash,
            :$maxDistance => max_meters
          }}
      )
  end

  def initialize(args)
    @id = args[:_id].nil? ? args[:id] : args[:_id].to_s
    @formatted_address = args[:formatted_address]
    @address_components = args[:address_components].nil? ? []
      : args[:address_components].map {|comp| AddressComponent.new(comp)}
    @location = Point.new(args[:geometry][:geolocation])
  end

  def destroy
    self.class.collection.find(_id: BSON::ObjectId.from_string(@id)).delete_one
  end

  def near(max_meters = nil)
    self.class.to_places(self.class.near(@location, max_meters))
  end

  def photos(offset = 0, limit = nil)
    result = Photo.find_photos_for_place(@id).skip(offset)
    result = result.limit(limit) unless limit.nil?
    result.map {|doc| Photo.new(doc)}
  end

  def persisted?
    !@id.nil?
  end

end
