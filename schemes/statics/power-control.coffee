lou = require "../lou"

# power-stuff: like restart, stop/start, etc...
module.exports = (raw, prefs, callback) ->

  lou.find.wheres "Can you meet me at 5:00 on monday at john's house", (r) ->
    console.log r

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
