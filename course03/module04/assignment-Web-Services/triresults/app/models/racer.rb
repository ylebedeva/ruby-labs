class Racer
  include Mongoid::Document
  embeds_one :info, as: :parent, autobuild: true, class_name: 'RacerInfo'
  has_many :races, class_name: 'Entrant', foreign_key: 'racer.racer_id', dependent: :nullify, order: :'race.date'.desc

  before_create { |racer| racer.info.racer_id = racer.id }

  delegate :first_name, :first_name=, to: :info
  delegate :last_name, :last_name=, to: :info
  delegate :gender, :gender=, to: :info
  delegate :birth_year, :birth_year=, to: :info
  delegate :city, :city=, to: :info
  delegate :state, :state=, to: :info
end
