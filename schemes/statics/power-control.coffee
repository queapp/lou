lou = require "../lou"

# power-stuff: like restart, stop/start, etc...
module.exports = (raw, prefs, callback) ->

  switch(raw)
    when "restart"
      # TODO restarty stuff here
      callback(null, {
        response: {
          action: "lou.power.restart",
          msg: "Lou is restarting - please wait..."
        },
        datapoints: {
          by: "statics.power-control"
        }
      });

    else
      callback null, null
