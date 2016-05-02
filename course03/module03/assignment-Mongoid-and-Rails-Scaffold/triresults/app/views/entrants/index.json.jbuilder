json.array!(@entrants) do |entrant|
  json.extract! entrant, :id, :place, :secs, :name, :bib, :city, :state, :gender, :gender_place, :group, :group_place, :swim, :pace_1000, :t1, :bike, :mph, :t2, :run, :min_mile
  json.url entrant_url(entrant, format: :json)
end
