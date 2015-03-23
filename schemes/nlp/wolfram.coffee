lou = require("../lou")
wa = require("wolfram-alpha")
_ = require("underscore")
natural = require("natural")
module.exports = (raw, prefs, callback) ->
  
  # callback(null, data) for success
  # callback(true, null) if data isn't relevant
  formatOutput = (raw, input) ->
    str = raw.trim()
    if str.indexOf("nown") isnt -1 or str.indexOf("adjective") isnt -1 or str.indexOf("verb") isnt -1
      
      # it's a definition
      str = _.map(str.split("\n"), (row) ->
        parts = row.split("|")
        
        # format into sentences.
        # do we have mutiple definitions?
        if parseInt(parts[0])
          parts[0] = natural.CountInflector.nth(parseInt(parts[0]))
          
          # put a word before the definition to introduce it better
          preword = ""
          preword = "to "  if parts[1].trim() is "verb"
          
          # the definition
          return parts[0] + ", a " + parts[1].trim() + ", " + preword + parts[2]
        else
          return "a " + parts[0] + " - " + parts[1]
        return
      )
      str = str.join("; ")
    if str.indexOf("|") isnt -1
      
      # 'table' formatting
      str = _.map(str.split("\n"), (row) ->
        parts = row.split("|")
        _.initial(parts).join(";") + ": " + _.last(parts).trim()
      ).join("; ")
    
    # return the formatted string
    str.replace "\n", " "

  lou.persistant.read "wolfram.apikey", (value) ->
    wolfram = wa.createClient(value, {})
    
    # do query
    wolfram.query raw, (err, result) ->
      primary_pod = result.filter((i) ->
        i.primary or _.intersection(i.title.toLowerCase().split(" "), [
          "information"
          "result"
        ]).length > 0
      )
      if primary_pod.length
        phrase = primary_pod[0].subpods.map((i) ->
          i.text
        ).join(" ")
        callback err,
          response:
            text: formatOutput(phrase, raw)

          datapoints:
            by: "nlp.wolfram"

      else
        
        # data isn't very good
        callback true, null
      return

    return

  return
