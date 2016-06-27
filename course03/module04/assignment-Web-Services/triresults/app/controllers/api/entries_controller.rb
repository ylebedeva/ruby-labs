module Api
  class EntriesController < ApplicationController
    def index
      if !request.accept || request.accept == '*/*'
        render plain: "/api/racers/#{params[:racer_id]}/entries"
      else
        # implementation
      end
    end
    def show
      if !request.accept || request.accept == '*/*'
        render plain: "/api/racers/#{params[:racer_id]}/entries/#{params[:id]}"
      else
        # implementation
      end
    end
  end
end
