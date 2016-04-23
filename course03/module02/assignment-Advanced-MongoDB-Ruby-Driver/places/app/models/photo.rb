require 'pp'
class Photo
  attr_accessor :id, :location
  attr_writer :contents

  MONGO_URL = 'mongodb://localhost:27017'
  MONGO_DATABASE = 'ruby-labs'

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

  def self.collection
    mongo_client if @@db.nil?
    @@db.database.fs
  end

  def self.all(skip = 0, limit = nil)
    result = collection.find.skip(skip)
    result = result.limit(limit) unless limit.nil?
    result.map {|doc| Photo.new(doc)}
  end

  def self.find(id)
    doc = collection.find(_id: BSON::ObjectId.from_string(id)).first
    Photo.new(doc) unless doc.nil?
  end

  def self.find_photos_for_place(place_id)
    collection.find('metadata.place' => BSON::ObjectId.from_string(place_id.to_s))
  end

  def initialize(args = {})
    @id = args[:_id].nil? ? args[:id] : args[:_id].to_s
    @location = Point.new(args[:metadata][:location]) unless args[:metadata].nil? or args[:metadata][:location].nil?
    @place = args[:metadata][:place] unless args[:metadata].nil? or args[:metadata][:place].nil?
  end

  def persisted?
    !@id.nil?
  end

  def save
    if persisted?
      self.class.collection.find(_id: BSON.ObjectId(@id)).update_one({
          :location => {:longitude => @location.longitude, :latitude => @location.latitude},
          :metadata => {:location => @location.to_hash, :place => @place}
        })
    else
      gps = EXIFR::JPEG.new(@contents).gps
      @contents.rewind

      point = Point.new({lng: gps.longitude, lat: gps.latitude})
      @location = point
      grid_file = Mongo::Grid::File.new(@contents.read, {
          :location => gps,
          :content_type => 'image/jpeg',
          :metadata => {:location => point.to_hash, :place => @place}
        })
      @id = self.class.collection.insert_one(grid_file).to_s
    end
  end

  def contents
    result = ''
    doc = self.class.collection.find_one(_id: BSON::ObjectId(@id))
    doc.chunks.reduce([]){|x, chunk| result << chunk.data.data}
    result
  end

  def place
    Place.find @place unless @place.nil?
  end

  def place=(id)
    case id
    when Place
      @place = BSON::ObjectId.from_string(id.id)
    when BSON::ObjectId
      @place = id
    when String
      @place = BSON::ObjectId.from_string(id)
    end
  end

  def destroy
    self.class.collection.find(_id: BSON::ObjectId(@id)).delete_one
  end

  def find_nearest_place_id(max_distance)
    result = Place.near(@location, max_distance).limit(1).projection({_id: true}).first
    result[:_id] unless result.nil?
  end

end
