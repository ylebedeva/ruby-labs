json.ignore_nil!
json.array!(@entrants) do |entrant|
  json.partial! "result", locals: {result: entrant}
end
