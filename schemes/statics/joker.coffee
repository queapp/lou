lou = require("../lou")

# well, this should tell jokes, but it doesn't yet.
module.exports = (raw, prefs, callback) ->
  switch raw
    when "joke"
      
      # TODO restarty stuff here
      callback null,
        response:
          text: "[Insert Joke Here]"

        datapoints:
          by: "statics.joker"

    else
      callback null, null
  return
