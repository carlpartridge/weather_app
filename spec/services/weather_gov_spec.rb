require 'rails_helper'

RSpec.describe(WeatherGov) do
  context('#get_forecast') do
    it('sends a request with lat, lon and returns a converted extended forecast data object') do
      result = WeatherGov.get_forecast({ lat: -76.9828, lon: 38.8794 })

      expect(result[:cached_response]).to eq(true).or eq(false)
      expect(result[:error]).to be_falsey
      expect(result[:forecast]).to be_present
      expect(result[:forecast][:current_temp]).to be_present
    end
  end
end
