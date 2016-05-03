class Placing
  include Mongoid::Document

  field :name, type: String
  field :place, type: Integer

  attr_accessor :name, :place

  def initialize(name, place)
    @name = name;
    @place = place;
  end

  def mongoize
    {name: @name, place: @place}
  end

  def self.demongoize(params)
    Placing.new(params[:name], params[:place]) unless params.nil?
  end

  def self.mongoize(arg)
    case (arg)
    when nil then arg
    when Placing then arg.mongoize
    when Hash then arg
    end
  end

  def self.evolve(arg)
    mongoize(arg)
  end
end
