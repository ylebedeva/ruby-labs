class LegResult
  include Mongoid::Document
  field :secs, type: Float

  after_initialize :calc_ave

  embedded_in :entrant
  embeds_one :event, as: :parent

  validates_presence_of :event

  def calc_ave

  end

  def secs=(secs)
    super(secs)
    calc_ave
  end
end
