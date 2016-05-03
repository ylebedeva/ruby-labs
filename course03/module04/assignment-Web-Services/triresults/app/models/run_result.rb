class RunResult < LegResult
  field :mmile, as: :minute_mile, type: Float

  def calc_ave
    self.minute_mile = secs / (60 * event.miles) unless secs.nil? or event.nil? or event.miles.nil?
  end
end
