class Race
  include Mongoid::Document
  include Mongoid::Timestamps

  field :n, as: :name, type: String
  field :date, type: Date
  field :loc, as: :location, type: Address
  field :next_bib, type: Integer, default: 0

  embeds_many :events, as: :parent, order: [:order.asc]
  has_many :entrants, foreign_key: 'race._id', dependent: :delete, order: [:secs.asc, :bib.asc]

  scope :past, -> { where(:date.lt => Date.current) }
  scope :upcoming, -> { where(:date.gte => Date.current) }

  %w(city state).each do |field|
    define_method(field) do
      location ? location.send(field) : nil
    end

    define_method("#{field}=") do |value|
      object = self.location ||= Address.new
      object.send("#{field}=", value)
      self.location = object
    end
  end

  DEFAULT_EVENTS = {
    'swim' => {order: 0, name: 'swim', distance: 1.0, units: 'miles'},
    't1' => {order: 1, name: 't1'},
    'bike' => {order: 2, name: 'bike', distance: 25.0, units: 'miles'},
    't2' => {order: 3, name: 't2'},
    'run' => {order: 4, name: 'run', distance: 10.0, units: 'kilometers'}
  }.freeze

  DEFAULT_EVENTS.keys.each do |event_name|
    define_method(event_name) do
      event = events.select { |e| event_name == e.name }.first
      event || events.build(DEFAULT_EVENTS[event_name])
    end

    %w(order distance units).each do |property|
      next unless DEFAULT_EVENTS[event_name][property.to_sym]
      define_method("#{event_name}_#{property}") do
        object = send(event_name)
        object.send(property)
      end

      define_method("#{event_name}_#{property}=") do |value|
        object = send(event_name)
        object.send("#{property}=", value)
      end
    end
  end

  def self.default
    Race.new(events: DEFAULT_EVENTS.values)
  end

  def self.upcoming_available_to(racer)
    upcoming_race_ids = racer.races.upcoming.pluck(:race).map {|r| r[:_id]}
    Race.upcoming.not_in(id: upcoming_race_ids)
  end

  def next_bib
    inc(next_bib: 1)
    self[:next_bib]
  end

  def get_group racer
    if racer && racer.birth_year && racer.gender
      quotient = (date.year - racer.birth_year) / 10
      min_age = quotient * 10
      max_age = min_age + 9
      gender = racer.gender
      name = min_age >= 60 ? "masters #{gender}" : "#{min_age} to #{max_age} (#{gender})"
      Placing.demongoize(:name=>name)
    end
  end

  def create_entrant(racer)
    entrant = Entrant.new
    entrant.race = attributes.symbolize_keys.slice(:_id, :n, :date)
    entrant.racer = racer.info.attributes
    entrant.group = get_group(racer)
    events.each { |event| entrant.send("#{event.name}=", event) }
    entrant.validate
    if entrant.valid?
      entrant.bib = next_bib
      entrant.save
    end
    entrant
  end
end
