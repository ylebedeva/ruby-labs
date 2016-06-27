module Api
  class RacersController < ApplicationController

    # GET /racers
    # GET /racers.json
    def index
      if !request.accept || request.accept == "*/*"
        render plain: "/api/racers"
      else
        #real implementation ...
      end
    end

    # GET /racers/1
    # GET /racers/1.json
    def show
        render plain: "/api/racers/#{params[:id]}"
      else
        #real implementation ...
      end
    end

end
