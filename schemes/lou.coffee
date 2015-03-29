fs = require "fs"
async = require "async"
_ = require "underscore"
natural = require "natural"
pos = require "pos"
chrono = require "chrono-node"

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
      if cb
        cb chrono.parse(raw) or [text: defaultLocation]
        return
      else
        return chrono.parse(raw) or [text: defaultLocation]

        # if there's a callback, then use it
        # if cb then cb text: "now" else text: "now"

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

      # search for the nowns, pronowns, and adjectives
      subjects = _.filter out, (token) ->
        [word, tag] = token
        'N' in tag or 'J' in tag or tag is 'PRP'

      # take those subjects and add the relevant data
      out = _.map subjects, (s) ->
        text: s[0],
        index: raw.indexOf s

      # if there's a callback, then use it
      if cb
        cb out
      else
        out

    # identify any places mentioned in the sentence
    # == For example ==
    # lou.find.wheres "Can you meet me at 5:00 on monday at john's house?", (r) ->
    #   console.log r
    # => { text: 'john's house', index: 37 }
    wheres: (raw, cb=null) ->
      done = false

      # what constitutes a place combo? (aka a where)
      templates = [
        # prepositional phrase terminated by punctuation
        /[ ](in|at) ([^0-9].*)(\.|\?|\!|\,|\;|\:)/gi

        # prepositional phrase terminated by end-of-string
        /[ ](in|at) ([^0-9].*) ?(?!yesterday)$/gi
      ]

      # check for matches from all the possible templates
      for i in templates
        matches = raw.match(i)

        if matches and matches.length
          m = matches[0].replace(/(at|in|\.|\?|\!|\,|\;|\:)/gi, '').trim() # normalize a match
          done = true

          # because of the similarity between wheres and whens,
          # let's do some filtering to get rid of any accidental
          # "when" input.
          @whens raw, (whens) ->
            for w in whens
              m = m.replace w.text, ""

            out =
              text: m.replace(/[0-9]/gi, "").trim(),
              index: raw.indexOf m

            # if there's a callback, then use it
            if cb
              cb out
              return
            else
              return out

          break

      # no location specified? Use the default.
      if not done
        lou.persistant.read "location.default", (defaultLocation) ->
          if cb then cb
            text: defaultLocation
            index: null

  # formatting of found types
  format:

    # format a date/time to fit into a sentence better
    whens: (whens) ->
      # convert to an array if not already
      whens = [whens] if not whens.length

      _.map _.flatten(whens), (w) ->
        return "at #{w.text}" if /(([012]?[0-9])(\:[0-5][0-9])?(\:[0-5][0-9])?) ?(am|pm)?/gi.exec(w.text) isnt null
        return "on #{w.text}" if /(monday|tuesday|wednesday|thursday|friday)/gi.exec(w.text) isnt null
        return "right now" if w.text.trim() is "now"
        w.text


  # change verbs to match the correct time frame of the query
  tenses: (raw, whens) ->
    now = new Date()
    date = whens[0] or whens
    date = date.ref if date.ref

    # no tense info? Just keep it how it is.
    if date.length is 0 then return raw

    verbConjugations =
      present: [
        {
          subjects: [
            /you/gi
            /they/gi
            /we/gi
          ]
          verb: "are"
        }
        {
          subjects: [
            /he/gi
            /she/gi
            /it/gi
          ]
          verb: "is"
        }
        {
          subjects: [
            /[iI]/gi
          ]
          verb: "am"
        }
      ]
      past: [
        {
          subjects: [
            /you/gi
            /they/gi
            /we/gi
          ]
          verb: "were"
        }
        {
          subjects: [
            /he/gi
            /she/gi
            /it/gi
          ]
          verb: "was"
        }
        {
          subjects: [
            /[iI]/gi
          ]
          verb: "was"
        }
      ]
      future: [
        {
          subjects: [
            /[iI]/gi
            /you/gi
            /they/gi
            /we/gi
            /he/gi
            /she/gi
            /it/gi
          ]
          verb: "will be"
        }
      ]


    # in the past, future, or present?
    switch

      # == past ==
      when now < date
        # console.log "PAST", now, date, now < date
        for conj in verbConjugations.past

          # find all the matching subjects
          matches = conj.subjects.filter (c) ->
            raw.match(c) isnt null

          if matches.length
            return raw.replace(/(was|were|am|are|is|will|will be)/gi, conj.verb)
          else
            return raw



      # == future ==
      when now > date
        # console.log "FUTR", now, date, now > date
        for conj in verbConjugations.future

          # find all the matching subjects
          matches = conj.subjects.filter (c) ->
            raw.match(c) isnt null

          if matches.length
            return raw.replace(/(was|were|am|are|is|will|will be)/gi, conj.verb)
          else
            return raw


      # == present ==
      else
        # console.log "PRES", now, date
        for conj in verbConjugations.present

          # find all the matching subjects
          matches = conj.subjects.filter (c) ->
            raw.match(c) isnt null

          if matches.length
            return raw.replace(/(was|were|am|are|is|will|will be)/gi, conj.verb)
          else
            return raw
