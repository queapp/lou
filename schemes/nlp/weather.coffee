lou = require("../lou")
_ = require("underscore")
chrono = require "chrono-node"
request = require "request"

module.exports = (raw, prefs, callback) ->
  # callback(null, data) for success
  # callback(true, null) if data isn't relevant

  whats = lou.find.whats raw

  # list of months
  months = [
    "Jan"
    "Feb"
    "Mar"
    "Apr"
    "May"
    "Jun"
    "Jul"
    "Aug"
    "Sep"
    "Oct"
    "Nov"
    "Dec"
  ]

  weatherWords = [
    "weather"
  ]

  precipWords = [
    "precipitation"
    "rain"
    "raining"
    "foggy"
    "fog"
    "cloud"
    "cloudy"
    "snow"
    "snowy"
    "snowing"
  ]

  tempWords = [
    "temperature"
    "tempurature"
    "hot"
    "cold"
  ]

  sunRiseSetWords = [
    "sun"
    "rise"
    "set"
    "sunrise"
    "sunset"
  ]

  humidityWords = [
    "humidity"
    "moistness"
    "moist"
    "dry"
    "dryness"
  ]

  # for testing below if a word list matches the query
  matches = (words) ->
    _.intersection(words, _.pluck(whats, 'text')).length

  # get date from a yahoo request
  getYahooDate = (body, whenDate) ->
    conditions = body.results.channel.item.condition
    if whenDate
      allConditions = body.results.channel.item.forecast.filter (i) ->
        [month, day, year] = whenDate.toString().split(" ").slice(1, 4)
        i.date is "#{day} #{month} #{year}"
      conditions = allConditions[0] if allConditions.length
    conditions


  # look for places and times specified within the sentence
  lou.find.wheres raw, (wheres) ->
    lou.find.whens raw, (whens) ->
      whenDate = new Date(whens.ref)

      switch

        # Tempurature: fetch temps
        when matches(tempWords)
          request
            url: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22"+wheres.text+"%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
            method: "get"
          , (error, response, body) ->
            body = (JSON.parse body or query: null).query

            cond = getYahooDate(body, whenDate)
            if cond.temp
              cond = "it is #{cond.temp} degrees"
            else
              cond = "the high is #{cond.high} degrees and the low is #{cond.low} degrees"

            callback null,
              response:
                msg: "#{cond} in #{wheres.text} #{lou.format.whens(whens)}".toLowerCase().trim()
              datapoints:
                by: "nlp.weather"

        # General Weather: just fetch the weather as a string
        when matches(weatherWords)
          request
            url: "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22"+wheres.text+"%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
            method: "get"
          , (error, response, body) ->
            body = (JSON.parse body or query: null).query

            callback null,
              response:
                msg: "it is #{getYahooDate(body, whenDate).text} in #{wheres.text} #{lou.format.whens(whens)}".toLowerCase().trim()
              datapoints:
                by: "nlp.weather"
                wheres: wheres
                whens: whens


        else
          # nevermind...
          callback true, null
