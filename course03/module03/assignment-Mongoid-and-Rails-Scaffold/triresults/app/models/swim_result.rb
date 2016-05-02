class SwimResult < LegResult

  field :pace_100, type: Float

  def calc_ave
    self.pace_100 = 100 * secs / event.meters unless secs.nil? or event.nil? or event.meters.nil?
  end
end
