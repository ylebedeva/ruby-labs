module Api
  class ResultsController < ApplicationController

    def index
      if !request.accept || request.accept == '*/*'
        render plain: "/api/races/#{params[:race_id]}/results"
      else
        @race = Race.find(params[:race_id])
        if stale? etag: @race, last_modified: @race.entrants.max(:updated_at), public: true
          @entrants = @race.entrants.where(:updated_at.gt => request.headers["If-Modified-Since"])
        else
          head :not_modified
        end
      end
    end

    def show
      if !request.accept || request.accept == '*/*'
        render plain: "/api/races/#{params[:race_id]}/results/#{params[:id]}"
      else
        set_result
        render partial: 'result', object: @result
      end
    end

    def update
      set_result
      changes = result_params
      entrant = @result
      if changes[:swim]
        entrant.swim = entrant.race.race.swim
        entrant.swim_secs = changes[:swim].to_f
      end
      if changes[:t1]
        entrant.t1 = entrant.race.race.t1
        entrant.t1_secs = changes[:t1].to_f
      end
      if changes[:bike]
        entrant.bike = entrant.race.race.bike
        entrant.bike_secs = changes[:bike].to_f
      end
      if changes[:t2]
        entrant.t2 = entrant.race.race.t2
        entrant.t2_secs = changes[:t2].to_f
      end
      if changes[:run]
        entrant.run = entrant.race.race.run
        entrant.run_secs = changes[:run].to_f
      end

      entrant.save
      render plain: :nothing, status: :ok
    end

    def set_result
      @result = Race.find(params[:race_id]).entrants.where(:id=>params[:id]).first
    end

    def result_params
      params.require(:result).permit(:swim, :t1, :bike, :t2, :run)
    end
  end
end
