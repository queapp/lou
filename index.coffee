natural = require("natural")
path = require("path")
async = require("async")
chalk = require("chalk")
_ = require("underscore")

# create express app and parse request body
app = require("express")()
bodyParser = require("body-parser")
app.use bodyParser.json()

# === session datapoints ===
data = []
durationBetweenSessions = 30 * 1000
query = module.exports = (raw, prefs, callback) ->
  prefs = prefs or {}
  console.log "---"

  # try each scheme, one at a time
  eachScheme = (raw, prefs, callback) ->
    async.mapSeries [
      "statics"
      "nlp"
      "dynamics"
    ], ((a, callback) ->
      mod = require("./" + path.join("schemes", a))
      mod raw, prefs, (err, resp) ->
        console.log chalk.red(a), resp
        if resp and resp.response

          # worked!
          callback true, resp
        else

          # scheme failed us
          callback err, null
        return

      return
    ), (err, outputs) ->

      # console.log("OUTPUTS", outputs);
      if outputs and outputs.length
        response = _.compact(outputs)[0]
      else
        response = "NOTHING"
      callback response
      return

    return


  # try the last handler that was invoked
  if prefs.session.length

    # where is the handler, exactly?
    lastHandler = _.last(prefs.session).by
    handlerPath = ["schemes"].concat(lastHandler.split("."))
    try
      mod = require("./" + path.join.apply(path, handlerPath))
    finally

      # call it
      mod and mod(raw, prefs, (err, resp) ->
        console.log chalk.red("previous"), chalk.yellow(lastHandler), resp
        if resp and resp.response

          # worked!
          callback resp
        else

          # scheme failed us
          eachScheme raw, prefs, callback
        return
      )
  else
    eachScheme raw, prefs, callback
  return


# === query-er ===
# Let the user perform a query on lou.
doSearch = (req, res) ->
  msg = req.query.q or req.query.query
  res.header "content-type": "application/json"
  if msg
    query msg,
      session: data
      body: req.body
    , (out) ->
      console.log chalk.yellow("out"), out.response

      # add datapoints
      if out.datapoints
        out.datapoints.timestamp = (new Date()).getTime()
        if data.length
          data.push out.datapoints
        else
          data = [out.datapoints]

      # and, send off the response
      res.send JSON.stringify(out)
      return

  else
    res.send JSON.stringify(error: "No Query Specified. Use parameter q or query.")
  return

app.post "/search", doSearch
app.get "/search", doSearch

# === datapoints ===
# Debug endpoint to show all the current datapoints.
app.get "/datapoints", (req, res) ->
  res.send JSON.stringify(data, null, 2)
  return


# === session garbage collector ===
# if the last query is over `durationBetweenSessions` old,
# terminate the current session. Most likely, the user has
# moved on by now, anyway.

# setInterval(function() {
#   now = (new Date()).getTime();
#   pt = _.last(data);
#   if ( pt && pt.timestamp + durationBetweenSessions > now) {
#     data = [];
#     console.log(chalk.blue("=> Current session has ended."))
#   }
# }, durationBetweenSessions);

# start listening for connections.
if not module.parent
  port = process.env.PORT or 8001
  console.log chalk.blue("=> The magic is at :" + port)
  app.listen port
