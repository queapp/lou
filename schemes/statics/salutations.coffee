lou = require("../lou")
_ = require("underscore")
module.exports = (raw, prefs, callback) ->

  salutations = [
    {
      search: [/thanks/gi, /thank you/gi]
      response: ["you are welcome", "you're welcome"]
    }
    {
      search: [/hi/gi, /hello/gi]
      response: ["hello yourself", "hello", "what's up", "how are you doing"]
    }
  ]

  for sal in salutations
    for s in sal.search
      if raw.match s
        callback null,
          response:
            text: _.sample(sal.response or sal.value)
          datapoints:
            by: "statics.salutations"

        return

  callback true, null
