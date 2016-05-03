class Point
  include Mongoid::Document

  attr_accessor :longitude, :latitude

  def initialize(lon, lat)
    @longitude = lon;
    @latitude = lat;
  end

  def mongoize
    {:type => 'Point', :coordinates => [@longitude, @latitude]}
  end

  def self.demongoize(params)
    coords = params[:coordinates] unless params.nil?
    Point.new(coords[0], coords[1]) unless coords.nil?
  end

  def self.mongoize(arg)
    case (arg)
    when nil then arg
    when Point then arg.mongoize
    when Hash then arg
    end
  end

  def self.evolve(arg)
    mongoize(arg)
  end

end
