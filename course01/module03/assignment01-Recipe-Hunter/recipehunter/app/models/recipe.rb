class Recipe
	include HTTParty
	hostport = ENV['FOOD2FORK_SERVER_AND_PORT'] || 'food2fork.com'
	base_uri "http://#{hostport}/api"
	default_params key: ENV['FOOD2FORK_KEY']
	format :json

  def self.for search
  	get("/search", query: { q: search })['recipes']
  end
end