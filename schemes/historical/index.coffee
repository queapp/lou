async = require "async"
_ = require "underscore"
natural = require "natural"
path = require "path"

# run all static queries
module.exports = (raw, prefs, callback) ->
  if prefs.historian
    log = prefs.historian.get()

    # get all the queries made in the history
    queries = _.map log, (l) ->
      in: l.in.text or l.in
      out: l and l.out and l.out.datapoints.by

    # load everything into a classifier
    classifier = new natural.BayesClassifier
    for q in _.compact queries
      classifier.addDocument q.in, q.out
    classifier.train()

    # now, classify the raw input
    queryBy = classifier.classify raw

    # and do the query
    error = false
    try
      mod = require "../" + path.join.apply(path, queryBy.split('.'))
    catch error
    finally
      # if there was any error in processing the query we'll
      # take care of that later on.
      if error is false
        mod raw, prefs, (err, resp) ->
          if resp
            callback err, resp
          else
            callback false, resp
          # callback null,
          #   response:
          #     text: error
          #   datapoints:
          #     by: queryBy
      else
        # the module doesn't exist, so nevermind...
        callback false, null

  else
    # without a history, we cannot do anything.
    callback false, null
