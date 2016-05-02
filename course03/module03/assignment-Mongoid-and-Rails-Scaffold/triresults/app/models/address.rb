class Address
  include Mongoid::Document

  field :city, type: String
  field :state, type: String
  field :loc, as: :location, type: Point

  attr_accessor :city, :state, :location

  def initialize(city = nil, state = nil, loc = nil)
    @city = city;
    @state = state;
    @location = loc;
  end

  def mongoize
    {city: @city, state: @state, loc: Point.mongoize(@location)}
  end

  def self.demongoize(args)
    Address.new(args[:city], args[:state], Point.demongoize(args[:loc])) unless args.nil?
  end

  def self.mongoize(arg)
    case (arg)
    when nil then arg
    when Address then arg.mongoize
    when Hash then arg
    end
  end

  def self.evolve(arg)
    mongoize(arg)
  end
end
