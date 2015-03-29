async = require "async"
_ = require "underscore"
reqs = [
  require("./joker")
  require("./location")
  require("./power-control")
  require("./salutations")
]

# run all static queries
module.exports = (raw, prefs, callback) ->
  async.mapSeries reqs, ((r, cb) ->
    r raw, prefs, (err, data) ->

      # do we have a decent response?
      if not err and data and data.response
        # cool, we're done.
        cb true, data
      else
        cb null, data
      return

    return
  ), (err, all) ->
    if all.length is 0
      callback true, null
    else
      match = _.compact(all)[0]
      callback null, match or null
    return

  return
