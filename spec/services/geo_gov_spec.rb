require 'rails_helper'

RSpec.describe(GeoGov) do
  context('#get') do
    it('sends a request with an address and gets the lat, lon') do
      result = GeoGov.get('1600 Pennsylvania Ave Washington DC')

      expect(result[:lat].round(4)).to eq(-76.9828)
      expect(result[:lon].round(4)).to eq(38.8794)
      expect(result[:error]).to be_nil
    end

    it('returns error with a bad address') do
      result = GeoGov.get('asdf')

      expect(result[:error]).to be_present
      expect(result[:lat]).to eq(0)
      expect(result[:lon]).to eq(0)
    end
  end
end
