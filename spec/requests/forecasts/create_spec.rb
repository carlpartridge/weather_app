require 'rails_helper'

RSpec.describe('/forecasts', type: :request) do
  context 'on success' do
    it 'should return the appropriate info' do
      post '/forecasts', as: :turbo_stream, params: { address: '1600 Pennsylvania Ave Washington DC' }
      
      expect(response.status).to eq(200)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('<turbo-stream action="update" target="forecast">')
      expect(response.body).to include('Humidity: ')
    end
  end

  context 'on failure' do
    it 'should return a failed status' do
      post '/forecasts', as: :turbo_stream, params: { address: 'asdf' }
      
      expect(response.status).to eq(200)
      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to include('<turbo-stream action="update" target="forecast">')
      expect(response.body).to include('There was an error')
    end
  end
end
