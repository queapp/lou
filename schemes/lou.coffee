fs = require "fs"
async = require "async"
_ = require "underscore"

lou = module.exports =
  persistant:
    location: "session/persistant.json"
    cache: {}

    # write to cache and file
    write: (name, value, callback) ->
      @cache[name] = value
      fs.writeFile @location, JSON.stringify(@cache, null, 2), (err, out) ->
        callback and callback(err, out)
        return

      return


    # read from cache
    read: (name, callback) ->
      if typeof @cache is "object" and Object.keys(@cache).length isnt 0
        callback @cache[name]
      else
        @generateCache (cache) ->
          callback cache[name]
          return

      return

    readAll: (names, callback) ->
      root = this
      async.map names, ((n, c) ->
        root.read n, (v) ->
          c null, v
          return

        return
      ), (err, all) ->
        callback.apply this, all
        return

      return


    # regenerate cache
    generateCache: (callback) ->
      fs.readFile @location, (err, data) ->
        @cache = JSON.parse(data.toString())
        callback and callback(cache)
        return

      return

  location:

    # get current location in lat and lng of a user
    getCurrentCoords: (prefs, callback) ->
      if prefs.body.location

        # use client location
        callback
          lat: prefs.body.location.lat
          lng: prefs.body.location.lng

      else
        lou.persistant.read "location.gps", (location) ->
          if location

            # use stored server location
            callback
              lat: location.lat
              lng: location.lng

          else

            # well, crap, we don't know where we are.
            callback
              lat: null
              lng: null

          return

      return


  # check on the current session to see if the last request was what was specified
  currentSession: (prefs, session) ->
    prefs.session.length and _.last(prefs.session).by is session


  # word lists for natural language stuff
  words:
    pronowns:
      first:
        sing: [
          "i"
          "my"
          "mine"
        ]
        plur: [
          "we"
          "our"
          "ours"
        ]

      second:
        sing: [
          "you"
          "your"
        ]
        plur: [
          "you"
          "your"
        ]

      third:
        sing: [
          "he"
          "she"
          "it"
          "him"
          "her"
          "his"
          "hers"
          "its"
        ]
        plur: [
          "we"
          "our"
          "ours"
        ]

    question: [
      "who"
      "what"
      "when"
      "where"
      "how"
    ]
