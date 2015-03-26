fs = require "fs"
async = require "async"
_ = require "underscore"
natural = require "natural"
pos = require "pos"

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

  # find sentence types
  find:

    tokenizer: new natural.TreebankWordTokenizer()

    # identify each date/time type in the sentence
    # == For example ==
    # lou.find.whens "Can you meet me at 5:00 on monday?", (r) ->
    #   console.log r
    # => { text: '5:00 on monday', index: 19 }
    whens: (raw, cb=null) ->

      # what constitutes a date/time combo? (aka a when)
      templates = [
        # time and absolute day (like "march 25", or "6pm on july 21, 1969")
        ///
        (([012]?[0-9])(\:[0-5][0-9])?(\:[0-5][0-9])?)? # time, which is optional
        ?(am|pm)? # am or pm, optional
        (on )? # optional prepositions
        ((january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|jun|jul|aug|sept|sep|oct|nov|dec)
        ([0-3]?[0-9](th|rd|st|nd)?) # month and day, with an optional suffix
        (, ?[0-9]*))/gi # optional year
        ///

        # time and day of week (like "5:00pm monday")
        /([012]?[0-9])\:([0-5][0-9])(\:[0-5][0-9])? ?(am|pm)? (on )? ?(today|tomorrow|yesterday|monday|tuesday|wednesday|thursday|friday)/gi

        # just times (like "5:00pm")
        /([012]?[0-9])\:([0-5][0-9])(\:[0-5][0-9])? ?(am|pm)?/gi
      ]

      # check for matches from all the possible templates
      for i in templates
        matches = raw.match(i)

        if matches and matches.length
          out =
            text: matches[0],
            index: raw.indexOf matches[0]

          # if there's a callback, then use it
          if cb
            cb out
          else
            out
          break

    # Return the subject(s) of the command
    # == For example ==
    # lou.find.whats "What time is it in san francisco?", (r) ->
    #  console.log r
    #  => {text: "time", index: 5}
    # Also:
    # - The milk is sour -> milk
    # - What time is it? -> time
    whats: (raw, cb=null) ->

      # tag each word in the sentence
      words = @tokenizer.tokenize raw
      out = new pos.Tagger().tag words

      # search for the nowns
      subjects = _.filter out, (token) ->
        [word, tag] = token
        tag is 'NN'

      # take those subjects and add the relevant data
      out = _.map subjects, (s) ->
        text: s[0],
        index: raw.indexOf s

      # if there's a callback, then use it
      if cb
        cb out
      else
        out
