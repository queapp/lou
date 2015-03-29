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

        callback null,
          response:
            msg: whenDate.toString()
            bits: whenDate.toString().split " "
          datapoints:
            by: "nlp.time"
            whens: whens

  callback true, null
