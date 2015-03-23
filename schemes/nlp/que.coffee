request = require("request")
lou = require("../lou")
_ = require("underscore")
module.exports = (raw, prefs, callback) ->
  
  # callback(null, data) for success
  # callback(true, null) if data isn't relevant
  
  # read hostname and api key
  lou.persistant.readAll [
    "que.apikey"
    "que.hostname"
  ], (key, host) ->
    if not key or not host
      callback true, null
      return
    
    # make the query
    request
      url: host + "/natural/query"
      method: "post"
      json: true
      body:
        data: raw
        assumptions:
          thing: (_.last(prefs.session) or {}).thing
          operation: (_.last(prefs.session) or {}).operation
          data: (_.last(prefs.session) or {}).data

      headers:
        "content-type": "application/json"
        authentication: key
    , (error, response, body) ->
      if typeof body is "string" and body.trim().toLowerCase() is "not authenticated"
        
        # isn't authenticated
        callback true, null
      else if typeof body isnt "object" or body.status.toUpperCase() is "ERR"
        
        # no relevant data returned
        callback null, null
      else
        
        # relevant data returned
        callback null,
          response:
            text: body.msg or body

          datapoints:
            by: "nlp.que"
            thing: body.thing
            operation: body.operation
            data: body.data

      return

    return

  return
