class ForecastsController < ApplicationController
  def index; end

  def create
    # get geolocation for lat, lon
    geo_data = geolocation_service.get(address)

    # get extended forecast data using lat, lon
    result = weather_service.get_forecast(geo_data)
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update(
          :forecast,
          partial: "forecasts/forecast_response",
          locals: {
            forecast: result[:forecast],
            cached_response: result[:cached_response],
            error: result[:error]
          }
        )
      end

      format.html { render :index }
    end
  end

  private

  def address
    params.permit(:address)[:address]
  end

  # TODO: allow for environment specific services
  def geolocation_service
    GeoGov
  end

  def weather_service
    WeatherGov
  end
end
