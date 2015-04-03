fs = require "fs"

class Historian

  constructor: (@logFile="session/history.json") ->
    @initLog (@log) =>

  # create the log file if is doesn't already exist
  initLog: (callback=null) ->
    fs.exists @logFile, (exists) =>
      if exists and callback
        fs.readFile @logFile, (err, data) ->
          callback JSON.parse(data) if callback
      else
        fs.writeFile @logFile, "[]", (err, data) ->
          callback() if callback

  # write out the log file
  putLog: (callback=null) ->
    fs.writeFile @logFile, JSON.stringify(@log, null, 2), (err, data) ->
      callback(err, data) if callback

  # add a request to the end of the query
  push: (request) ->
    if request.in and request.out
      @log.push request
      @putLog()
      true
    else
      false

  # get the whole log
  get: () ->
    return @log


module.exports = Historian
