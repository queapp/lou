natural = require("natural")
wordnet = new natural.WordNet()
_ = require("underscore")
chalk = require("chalk")
async = require("async")
DBG = ->


# main class
module.exports = (apis) ->
  root = this
  @nounInflector = new natural.NounInflector()
  
  # return the value of the specified record.
  @getValue = (x) ->
    if typeof x is "function"
      x()
    else
      x

  
  # create a corpus of the specified words
  # and their synonyms
  @makeCorpusForWords = (words, callback) ->
    corpus = []
    async.forEach words, ((word, callback) ->
      
      # add word to corpus
      corpus.push word
      singularWord = root.nounInflector.singularize(word)
      
      # lookup a corpus word
      DBG "Looking up", chalk.blue(singularWord)
      wordnet.lookup singularWord, (results) ->
        results.forEach (result) ->
          
          # DBG("-> Adding", JSON.stringify(result.synonyms), "to corpus b/c of", chalk.blue(word));
          corpus = corpus.concat(result.synonyms)
          return

        callback()
        return

      return
    ), (err) ->
      
      # completed corpus
      DBG "Corpus:", JSON.stringify(corpus)
      callback null, _.uniq(corpus)
      return

    return

  
  # search for the specified words in the haystack
  @searchFor = (haystack, words, callback) ->
    @makeCorpusForWords words, (err, corpus) ->
      throw err  if err
      
      # check for relevancy with the corpus
      relevancies = _.map(haystack, (remote, ct) ->
        _.intersection(root.getValue(remote.tags), corpus).length
      )
      
      # the most relevant remote
      winner_index = relevancies.indexOf(_.max(relevancies))
      winner = haystack[winner_index]
      DBG "Haystack Winner:", chalk.blue(root.getValue(winner.name))
      callback null, winner
      return

    return

  
  # determine crud operations for a phrase
  @determineCRUDOperation = (words, callback) ->
    
    # split words, if necessary
    words = words.split(" ")  if typeof words isnt "object"
    
    # define corpora
    createWords = [
      "create"
      "add"
      "build"
      "conceive"
      "constitute"
      "construct"
      "design"
      "devise"
      "establish"
      "forge"
      "spawn"
      "found"
      "initiate"
      "make"
      "new"
      "start"
    ]
    readWords = [
      "read"
      "interpret"
      "scan"
      "see"
      "study"
      "translate"
      "view"
      "skim"
    ]
    updateWords = [
      "update"
      "amend"
      "modernize"
      "renew"
      "restore"
      "revise"
      "set"
      "enable"
      "disable"
      "turn"
      "on"
      "off"
    ]
    deleteWords = [
      "delete"
      "remove"
      "destroy"
      "annul"
      "trash"
      "eliminate"
      "cancel"
      "revoke"
    ]
    
    # test for crud operation
    if _.intersection(words, createWords).length
      callback null, "create"
    else if _.intersection(words, readWords).length
      callback null, "read"
    else if _.intersection(words, updateWords).length
      callback null, "update"
    else if _.intersection(words, deleteWords).length
      callback null, "delete"
    else
      callback new Error("No operation found.")
    return

  
  # parse a string for variable replacements
  @evaluate = (cxt, x, callback) ->
    switch typeof x
      when "string"
        
        # find all variable substitutions
        (x.match(/(\{\{([A-Za-z0-9_-]*)\}\})/g) or []).forEach (i) ->
          name = i.replace("{{", "").replace("}}", "")
          
          # get var value
          varResult = _.filter(cxt.variables or cxt, (i, k) ->
            k is name
          )
          if varResult.length
            
            # interpolate value into string
            putAt = x.indexOf(i)
            varResult[0] {}, (result) ->
              x = x.replace(i, result)
              return

          return

        callback null, x
      when "object"
        async.map x, ((val, callback) ->
          
          # console.log(val)
          root.evaluate cxt, val, callback
          return
        ), callback

  return
