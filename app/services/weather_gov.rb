# US govt Weather API service, see:
# https://weather-gov.github.io/api/general-faqs

# This module is handling how and where to get the data as well
# as converting that into a specific, useful format for the FE
module WeatherGov
  def self.get_forecast(data)
    # need to send request to get wfo using lat, lon first
    forecast_url = get_point(data)

    # use above response to get extended forecast url
    # using the forecast url as the caching key as it contains specific
    # geolocation data eg https://.../gridpoints/LWX/101,70/forecast/hourly
    cached = false
    response = if Rails.cache.exist?(forecast_url)
      cached = true
      Rails.cache.fetch(forecast_url)
    else
      result = Faraday.get(forecast_url)
      body = JSON.parse(result.body)
      Rails.cache.write(forecast_url, body)
      body
    end

    # parse response data and convert to standard response
    forecast = calculate_extended_forecast(response)

    {
      error: nil,
      cached_response: cached,
      forecast: forecast,
    }
  rescue StandardError => err
    # TODO: better error loggin/alerting/reporting
    {
      error: err,
      cached_response: false,
      forecast: nil,
    }
  end
  # example response
  # {
  #   "@context": [
  #     "https://geojson.org/geojson-ld/geojson-context.jsonld",
  #     {
  #       "@version": "1.1",
  #       "wx": "https://api.weather.gov/ontology#",
  #       "geo": "http://www.opengis.net/ont/geosparql#",
  #       "unit": "http://codes.wmo.int/common/unit/",
  #       "@vocab": "https://api.weather.gov/ontology#"
  #     }
  #   ],
  #   "type": "Feature",
  #   "geometry": {
  #     "type": "Polygon",
  #     "coordinates": [
  #       [
  #         [
  #           -76.9279787,
  #           38.8670956
  #         ],
  #         [
  #           -76.93175719999999,
  #           38.845150499999995
  #         ],
  #         [
  #           -76.90357589999999,
  #           38.8422055
  #         ],
  #         [
  #           -76.89979159999999,
  #           38.8641503
  #         ],
  #         [
  #           -76.9279787,
  #           38.8670956
  #         ]
  #       ]
  #     ]
  #   },
  #   "properties": {
  #     "units": "us",
  #     "forecastGenerator": "HourlyForecastGenerator",
  #     "generatedAt": "2024-08-15T18:54:48+00:00",
  #     "updateTime": "2024-08-15T17:30:19+00:00",
  #     "validTimes": "2024-08-15T11:00:00+00:00/P7DT17H",
  #     "elevation": {
  #       "unitCode": "wmoUnit:m",
  #       "value": 75.8952
  #     },
  #     "periods": [
  #       {
  #         "number": 1,
  #         "name": "",
  #         "startTime": "2024-08-15T14:00:00-04:00",
  #         "endTime": "2024-08-15T15:00:00-04:00",
  #         "isDaytime": true,
  #         "temperature": 87,
  #         "temperatureUnit": "F",
  #         "temperatureTrend": "",
  #         "probabilityOfPrecipitation": {
  #           "unitCode": "wmoUnit:percent",
  #           "value": 0
  #         },
  #         "dewpoint": {
  #           "unitCode": "wmoUnit:degC",
  #           "value": 15
  #         },
  #         "relativeHumidity": {
  #           "unitCode": "wmoUnit:percent",
  #           "value": 39
  #         },
  #         "windSpeed": "5 mph",
  #         "windDirection": "N",
  #         "icon": "https://api.weather.gov/icons/land/day/few?size=small",
  #         "shortForecast": "Sunny",
  #         "detailedForecast": ""
  #       },
  #       {
  #         "number": 2,
  #         "name": "",
  #         "startTime": "2024-08-15T15:00:00-04:00",
  #         "endTime": "2024-08-15T16:00:00-04:00",
  #         "isDaytime": true,
  #         "temperature": 88,
  #         "temperatureUnit": "F",
  #         "temperatureTrend": "",
  #         "probabilityOfPrecipitation": {
  #           "unitCode": "wmoUnit:percent",
  #           "value": 0
  #         },
  #         "dewpoint": {
  #           "unitCode": "wmoUnit:degC",
  #           "value": 14.444444444444445
  #         },
  #         "relativeHumidity": {
  #           "unitCode": "wmoUnit:percent",
  #           "value": 36
  #         },
  #         "windSpeed": "5 mph",
  #         "windDirection": "N",
  #         "icon": "https://api.weather.gov/icons/land/day/few?size=small",
  #         "shortForecast": "Sunny",
  #         "detailedForecast": ""
  #       },
  #     ...
  #     this gets roughly 7 days worth of records (per hour)

  private

  def self.base_url
    'https://api.weather.gov'
  end

  def self.point_url(data)
    URI("#{base_url}/points/#{data[:lon].round(4)},#{data[:lat].round(4)}")
  end

  def self.get_point(data)
    response = Faraday.get(point_url(data))

    # this returns a url specific to the weather office and lat, lon
    JSON.parse(response.body)['properties']['forecastHourly']
  rescue StandardError => err
    {
      error: err
    }
  end
  # {
  #   "@context": [
  #     "https://geojson.org/geojson-ld/geojson-context.jsonld",
  #     {
  #       "@version": "1.1",
  #       "wx": "https://api.weather.gov/ontology#",
  #       "s": "https://schema.org/",
  #       "geo": "http://www.opengis.net/ont/geosparql#",
  #       "unit": "http://codes.wmo.int/common/unit/",
  #       "@vocab": "https://api.weather.gov/ontology#",
  #       "geometry": {
  #         "@id": "s:GeoCoordinates",
  #         "@type": "geo:wktLiteral"
  #       },
  #       "city": "s:addressLocality",
  #       "state": "s:addressRegion",
  #       "distance": {
  #         "@id": "s:Distance",
  #         "@type": "s:QuantitativeValue"
  #       },
  #       "bearing": {
  #         "@type": "s:QuantitativeValue"
  #       },
  #       "value": {
  #         "@id": "s:value"
  #       },
  #       "unitCode": {
  #         "@id": "s:unitCode",
  #         "@type": "@id"
  #       },
  #       "forecastOffice": {
  #         "@type": "@id"
  #       },
  #       "forecastGridData": {
  #         "@type": "@id"
  #       },
  #       "publicZone": {
  #         "@type": "@id"
  #       },
  #       "county": {
  #         "@type": "@id"
  #       }
  #     }
  #   ],
  #   "id": "https://api.weather.gov/points/38.8459999,-76.9274",
  #   "type": "Feature",
  #   "geometry": {
  #     "type": "Point",
  #     "coordinates": [
  #       -76.9274,
  #       38.8459999
  #     ]
  #   },
  #   "properties": {
  #     "@id": "https://api.weather.gov/points/38.8459999,-76.9274",
  #     "@type": "wx:Point",
  #     "cwa": "LWX",
  #     "forecastOffice": "https://api.weather.gov/offices/LWX",
  #     "gridId": "LWX",
  #     "gridX": 101,
  #     "gridY": 70,
  #     "forecast": "https://api.weather.gov/gridpoints/LWX/101,70/forecast",
  #     "forecastHourly": "https://api.weather.gov/gridpoints/LWX/101,70/forecast/hourly",
  #     "forecastGridData": "https://api.weather.gov/gridpoints/LWX/101,70",
  #     "observationStations": "https://api.weather.gov/gridpoints/LWX/101,70/stations",
  #     "relativeLocation": {
  #       "type": "Feature",
  #       "geometry": {
  #         "type": "Point",
  #         "coordinates": [
  #           -76.92252,
  #           38.848615
  #         ]
  #       },
  #       "properties": {
  #         "city": "Suitland",
  #         "state": "MD",
  #         "distance": {
  #           "unitCode": "wmoUnit:m",
  #           "value": 512.98953576715
  #         },
  #         "bearing": {
  #           "unitCode": "wmoUnit:degree_(angle)",
  #           "value": 235
  #         }
  #       }
  #     },
  #     "forecastZone": "https://api.weather.gov/zones/forecast/MDZ013",
  #     "county": "https://api.weather.gov/zones/county/MDC033",
  #     "fireWeatherZone": "https://api.weather.gov/zones/fire/MDZ013",
  #     "timeZone": "America/New_York",
  #     "radarStation": "KLWX"
  #   }
  # }

  # TODO: clean this up, eventually have standardized output classes/objects
  def self.calculate_extended_forecast(json)
    # group by day and into nicer format, "2024-08-15T14:00:00-04:00" -> "08-15"
    sorted_daily = json['properties']['periods'].group_by do |data|
      data['startTime'].split("T")[0].split("-")[1,2].join("-")
    end

    {
      current_temp: json['properties']['periods'][0]['temperature'],
      current_humidity: json['properties']['periods'][0]['relativeHumidity']['value'],
      short_desc: json['properties']['periods'][0]['shortForecast'],
      daily: sorted_daily.map do |date, data|
        {
          date: date,
          high: data.map { |d| d['temperature'] }.max,
          low: data.map { |d| d['temperature'] }.min,
        }
      end
    }
  end
  # example output structure
  # {
  #   current_temp: 87, 
  #   current_humidity: 39, 
  #   short_desc: "Mostly Sunny", 
  #   daily: [{
  #     date: "2024-08-15", 
  #     high: 87, 
  #     low: 75
  #   }, {
  #     date: "2024-08-16", 
  #     high: 88, 
  #     low: 69
  #   }, {
  #     date: "2024-08-17", 
  #     high: 82, 
  #     low: 73
  #   }, {
  #     date: "2024-08-18", 
  #     high: 81, 
  #     low: 72
  #   }, {
  #     date: "2024-08-19", 
  #     high: 83, 
  #     low: 72
  #   }, {
  #     date: "2024-08-20", 
  #     high: 77, 
  #     low: 69
  #   }, {
  #     date: "2024-08-21", 
  #     high: 78, 
  #     low: 66
  #   }, {
  #     date: "2024-08-22", 
  #     high: 67, 
  #     low: 66
  #   }
  # ]}
end
