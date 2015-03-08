var natural = require("natural");
var wordnet = new natural.WordNet();

var _ = require("underscore");
var chalk = require('chalk');
var async = require("async");

var DBG = function(){};

// main class
module.exports = function(apis) {
  var root = this;

  this.nounInflector = new natural.NounInflector();

  // return the value of the specified record.
  this.getValue = function(x) {
    if (typeof x === "function") {
      return x();
    } else {
      return x;
    }
  };

  // create a corpus of the specified words
  // and their synonyms
  this.makeCorpusForWords = function(words, callback) {
    corpus = [];

    async.forEach(words, function(word, callback) {
      // add word to corpus
      corpus.push(word);
      singularWord = root.nounInflector.singularize(word);

      // lookup a corpus word
      DBG("Looking up", chalk.blue(singularWord));

      wordnet.lookup(singularWord, function(results) {
        results.forEach(function(result) {
          // DBG("-> Adding", JSON.stringify(result.synonyms), "to corpus b/c of", chalk.blue(word));
          corpus = corpus.concat(result.synonyms);
        });

        callback();
      });
    }, function(err) {
      // completed corpus
      DBG("Corpus:", JSON.stringify(corpus));
      callback(null, _.uniq(corpus));
    });

  };

  // search for the specified words in the haystack
  this.searchFor = function(haystack, words, callback) {
    this.makeCorpusForWords(words, function(err, corpus) {
      if (err) throw err;

      // check for relevancy with the corpus
      var relevancies = _.map(haystack, function(remote, ct) {
        return _.intersection(root.getValue(remote.tags), corpus).length;
      });

      // the most relevant remote
      var winner_index = relevancies.indexOf(_.max(relevancies));
      var winner = haystack[winner_index];

      DBG("Haystack Winner:", chalk.blue(root.getValue(winner.name)));
      callback(null, winner);
    });
  };

  // determine crud operations for a phrase
  this.determineCRUDOperation = function(words, callback) {

    // split words, if necessary
    if (typeof words !== "object") words = words.split(' ');

    // define corpora
    createWords = ["create", "add", "build", "conceive", "constitute", "construct", "design", "devise", "establish", "forge", "spawn", "found", "initiate", "make", "new", "start"]
    readWords = ["read", "interpret", "scan", "see", "study", "translate", "view", "skim"]
    updateWords = ["update", "amend", "modernize", "renew", "restore", "revise", "set", "enable", "disable", "turn", "on", "off"]
    deleteWords = ["delete", "remove", "destroy", "annul", "trash", "eliminate", "cancel", "revoke"]

    // test for crud operation
    if (_.intersection(words, createWords).length) {
      callback(null, "create");
    } else if (_.intersection(words, readWords).length) {
      callback(null, "read");
    } else if (_.intersection(words, updateWords).length) {
      callback(null, "update");
    } else if (_.intersection(words, deleteWords).length) {
      callback(null, "delete");
    } else callback(new Error("No operation found."));

  }

  // parse a string for variable replacements
  this.evaluate = function(cxt, x, callback) {
    switch(typeof x) {
      case "string":

        // find all variable substitutions
        (x.match(/(\{\{([A-Za-z0-9_-]*)\}\})/gi) || []).forEach(function(i) {
          name = i.replace('{{', '').replace('}}', '');

          // get var value
          varResult = _.filter(cxt.variables || cxt, function(i, k) {
            return k === name;
          });
          if (varResult.length) {
            // interpolate value into string
            putAt = x.indexOf(i);
            varResult[0]({}, function(result) {
              x = x.replace(i, result);
            });
          };
        });

        callback(null, x);
        break;

      case "object":
        async.map(x, function(val, callback) {
          console.log(val)
          root.evaluate(cxt, val, callback);
        }, callback);
        break;
    }
  };
};
