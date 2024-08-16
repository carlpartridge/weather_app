### Design Decisions:
* Hotwire (turbo) over JS for DOM reactivity: I haven't used hotwire before and this project felt like a quick and easy entry point to dip my feet.
* Local memory cache store for now.  Quick and easy.  Once we start thinking about scaling we can come back to this and use a more appropriate tool (eg [Redis](https://redis.io)).
* Frontend style framework: [MVP.css](https://github.com/andybrewer/mvp) is super quick and easy and looks good enough so I can pretend Im not mainly a backend programmer :)
* Very light on testing.  Really only one endpoint that goes directly numerous through external APIs (See TODO on testing external APIs).  Frontend form is also super light, did not seem worth setting up a heavier duty testing framework (eg [Capybara](https://github.com/teamcapybara/capybara)).
* Did not spend much time on security.  Rails handles a lot of basic form validation/sanitization/security and theres not much else going on here.

### TODO:
* A lot of room for improvement in the UI!  Didnt spend too much time here...
  * More and better display of info, we get a lot of data points, we could display more.  But we would have to filter things in complex ways which would be products call in my opinion (eg How do we determine if a whole day is going to be "Mostly Sunny" vs "Occasional Rain"?  Would people want to see the humidity for everyday of the week or is that too much info?)
  * Some lacking data edge cases
    * High/low for current day is off as we only get current time to future data, no past data.  I couldnt find anything specific in the API I chose at the beginning, though it shouldnt be too hard to swap that one out if need be.
    * We dont seem to get the full info for the 7th day so cutting that off as that was showing seemingly incorrect highs/lows.
* Move external api example responses to documentation elsewhere.  Fine where they are now, but could become pretty cluttered if/when more routes/functionality is added.
* Better testing for external APIs:  Use [VCR](https://github.com/vcr/vcr) or set up mock implementations for testing of external APIs.
* Better error logging, reporting, alerting.  Right now we catch everything and display a small note in the FE.
  * At some point we should be capturing specifics and logging/alerting/reporting on them (eg [Sentry](https://sentry.io/welcome/)).  This allows us to easily see and debug issues.
  * User would likely appreciate better error messages.

### Local Setup/Testing:
* install ruby 3.2.2
* run `bundle install`
* run `rails s` to start a local server at `localhost:3000`
  * Open up `localhost:3000` in a browser
  * Enter an address and click 'Get Forecast'
  * Results will pop up underneath
* run `rspec` to run tests
