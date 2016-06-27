module Api
  class RacesController < ApplicationController
    before_action :set_race, only: [:update, :destroy]
    before_action :set_format, only: [:update]
    protect_from_forgery with: :null_session
    rescue_from Mongoid::Errors::DocumentNotFound do |exception|
      if !request.accept || request.accept == '*/*'
        render plain: "woops: cannot find race[#{params[:id]}]", status: :not_found
      else
        @msg = "woops: cannot find race[#{params[:id]}]"
        if request.format.json?
          render json: {msg: @msg}, status: :not_found
        else
          render action: :error, status: :not_found
        end
      end
    end
    rescue_from ActionView::MissingTemplate do |exception| 
      Rails.logger.debug exception
      render plain: "woops: we do not support that content-type[#{request.accept}]", status: :unsupported_media_type
    end

    # GET /races
    # GET /races.json
    def index
      if !request.accept || request.accept == '*/*'
        render plain: "/api/races, offset=[#{params[:offset]}], limit=[#{params[:limit]}]"
      else
        # implementation
      end
    end

    # GET /races/1
    # GET /races/1.json
    def show
      if !request.accept || request.accept == '*/*'
        render plain: "/api/races/#{params[:id]}"
      else
        set_race
        if @race
          render action: :race
        end
      end
    end

    def create
      if !request.accept || request.accept == '*/*'
        render plain: params[:race][:name], status: :ok
      else
        @race = Race.create race_params
        render plain: @race.name, status: :created
      end
    end

    def update 
      @race.update(race_params)
      if request.headers["Content-Type"].include? "application/json"
        render json: @race
      else
        render xml: @race
      end
    end
    
    def destroy
      @race.destroy
      render nothing: true, status: :no_content
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_race
      @race = Race.find(params[:id])
    end

    def set_format
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def race_params
      params.require(:race).permit(:name, :date, :city, :state, :swim_distance, :swim_units, :bike_distance, :bike_units, :run_distance, :run_units) if params["race"]
    end
  end
end
