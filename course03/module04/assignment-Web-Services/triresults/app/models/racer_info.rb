class RacerInfo
  include Mongoid::Document
  field :_id, default: -> { racer_id }
  field :racer_id, as: :_id
  field :fn, as: :first_name, type: String
  field :ln, as: :last_name, type: String
  field :g, as: :gender, type: String
  field :yr, as: :birth_year, type: Integer
  field :res, as: :residence, type: Address

  embedded_in :parent, polymorphic: true

  validates_presence_of :first_name, :last_name
  validates :gender, presence: true, inclusion: { in: %w(F M) }
  validates :birth_year, presence: true, numericality: {
    less_than: Date.current.year,
    message: 'must be in the past'
  }

  %w(city state).each do |action|
    define_method("#{action}") do
      residence ? residence.send("#{action}") : nil
    end

    define_method("#{action}=") do |name|
      object = self.residence ||= Address.new
      object.send("#{action}=", name)
      self.residence = object
    end
  end

end
