# US Census Bureau geocoding API service, see:
# https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html

# This module is handling how and where to get the data as well
# as converting that into a specific, useful format
module GeoGov
  def self.get(address)
    response = Faraday.get(query_url(address))

    {
      lat: JSON.parse(response.body)['result']['addressMatches'][0]['coordinates']['x'],
      lon: JSON.parse(response.body)['result']['addressMatches'][0]['coordinates']['y'],
      error: nil,
    }
  rescue StandardError => err
    # TODO: better error loggin/alerting/reporting
    {
      lat: 0,
      lon: 0,
      error: err,
    }
  end
  # example response
  # {
  #   "result": {
  #     "input": {
  #       "address": {"address": "4600 Silver Hill Rd, Washington, DC 20233"},
  #       "benchmark": {
  #         "isDefault": true,
  #         "benchmarkDescription": "Public Address Ranges - Current Benchmark",
  #         "id": "4",
  #         "benchmarkName": "Public_AR_Current"
  #       }
  #     },
  #     "addressMatches": [{
  #         "tigerLine": {
  #             "side": "L",
  #             "tigerLineId": "76355984"
  #         },
  #         "coordinates": {
  #           "x": -76.92748724230096,
  #           "y": 38.84601622386617
  #         },
  #         "addressComponents": {
  #           "zip": "20233",
  #           "streetName": "SILVER HILL",
  #           "preType": "",
  #           "city": "WASHINGTON",
  #           "preDirection": "",
  #           "suffixDirection": "",
  #           "fromAddress": "4600",
  #           "state": "DC",
  #           "suffixType": "RD",
  #           "toAddress": "4700",
  #           "suffixQualifier": "",
  #           "preQualifier": ""
  #         },
  #       "matchedAddress": "4600 SILVER HILL RD, WASHINGTON, DC, 20233"
  #     }]
  #   }
  # }

  private

  def self.base_url
    'https://geocoding.geo.census.gov/geocoder/locations/onelineaddress'
  end

  def self.query_url(address)
    URI(base_url + '?address=' + address + '&benchmark=4&format=json')
  end
end
