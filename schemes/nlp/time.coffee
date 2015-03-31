lou = require "../lou"
_ = require "underscore"

# power-stuff: like restart, stop/start, etc...
module.exports = (raw, prefs, callback) ->
  # callback(null, data) for success
  # callback(true, null) if data isn't relevant

  lou.find.whats raw, (whats) ->
    words = _.pluck whats, "text"

    if "time" in words
      lou.find.whens raw, (whens) ->
        whenDate = whens.ref or new Date()
        whenDate = whens[0].ref or whens[0] if whens.length

        hours = whenDate.getHours()
        hours -= 12 if hours > 12

        min = (whenDate.getMinutes()).toString()
        min = "0" + min if min < 10

        ampm = whenDate.getHours() > 12 and "PM" or "AM"

        callback null,
          response:
            msg: "It is #{hours}:#{min} #{ampm}"
            bits: whenDate.toString().split " "
          datapoints:
            by: "nlp.time"
            whens: whens
    else
      callback true, null
