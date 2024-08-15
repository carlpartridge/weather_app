class ForecastsController < ApplicationController
  def index; end

  def create
    @forecast = address
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          :forecast,
          partial: "forecasts/forecast_response",
          locals: { forecast: @forecast }
        )
      end

      format.html { render :index }
    end
  end

  private

  def address
    params.permit(:address)[:address]
  end
end
