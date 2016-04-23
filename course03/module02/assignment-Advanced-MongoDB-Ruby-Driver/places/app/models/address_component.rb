class AddressComponent
  PROPERTIES = [:long_name, :short_name, :types].freeze
  attr_reader *PROPERTIES

  def initialize(args)
    PROPERTIES.each do |k|
      instance_variable_set("@#{k}", args[k]) unless args[k].nil?
    end
  end
end
