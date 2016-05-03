class BikeResult < LegResult
  field :mph, type: Float

  def calc_ave
    self.mph = 3600 * event.miles / secs unless secs.nil? or event.nil? or event.miles.nil?
  end
end
