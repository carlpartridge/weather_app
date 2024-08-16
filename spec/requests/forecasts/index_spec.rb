require 'rails_helper'

RSpec.describe('/forecasts', type: :request) do
  context '#index' do
    it 'should load properly' do
      get '/forecasts'

      expect(response.status).to eq(200)
      expect(response.body).to include('<input type="text" name="address" id="address" />')
      expect(response.body).to include('<input type="submit" name="commit" value="Get Forecast"')
    end
  end
end
