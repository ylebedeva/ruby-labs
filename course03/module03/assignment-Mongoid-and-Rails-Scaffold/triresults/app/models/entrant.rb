class Entrant
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'results'

  field :bib, type: Integer
  field :secs, type: Float
  field :o, as: :overall, type: Placing
  field :gender, type: Placing
  field :group, type: Placing

  embeds_many :results, order: [:"event.o".asc], class_name: 'LegResult', after_add: :update_total, after_remove: :update_total
  embeds_one :race, class_name: 'RaceRef', autobuild: true
  embeds_one :racer, as: :parent, class_name: 'RacerInfo', autobuild: true

  delegate :first_name, :first_name=, to: :racer
  delegate :last_name, :last_name=, to: :racer
  delegate :gender, :gender=, to: :racer, prefix: 'racer'
  delegate :birth_year, :birth_year=, to: :racer
  delegate :city, :city=, to: :racer
  delegate :state, :state=, to: :racer
  delegate :name, :name=, to: :race, prefix: 'race'
  delegate :date, :date=, to: :race, prefix: 'race'

  scope :past, -> { where(:'race.date'.lt => Date.current) }
  scope :upcoming, -> { where(:'race.date'.gte => Date.current) }

  RESULTS = {
    'swim' => SwimResult,
    't1' => LegResult,
    'bike' => BikeResult,
    't2' => LegResult,
    'run' => RunResult
  }.freeze

  RESULTS.keys.each do |name|
    # create_or_find result
    define_method("#{name}") do
      result = results.select { |r| name == r.event.name if r.event }.first
      unless result
        result = RESULTS["#{name}"].new(event: {name: name})
        results << result
      end
      result
    end
    # assign event details to result
    define_method("#{name}=") do |event|
      send("#{name}").build_event(event.attributes)
    end
    # expose setter/getter for each property of each result
    RESULTS["#{name}"].attribute_names.reject { |r| /^_/ === r }.each do |prop|
      define_method("#{name}_#{prop}") do
        send(name).send(prop)
      end
      define_method("#{name}_#{prop}=") do |value|
        send(name).send("#{prop}=", value)
        update_total nil if prop == 'secs'
      end
    end
  end

  def update_total(res)
    self.secs = results.each.inject(0){|sum, result| sum + (result.secs || 0)}
  end

  def the_race
    race.race
  end

  def overall_place
    overall.place if overall
  end

  def gender_place
    gender.place if gender
  end

  def group_name
    group.name if group
  end

  def group_place
    group.place if group
  end
end
