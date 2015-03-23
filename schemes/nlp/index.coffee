async = require("async")
_ = require("underscore")
reqs = [
  require("./weather")
  require("./que")
  require("./wolfram")
]

# run all nlp stuff
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
