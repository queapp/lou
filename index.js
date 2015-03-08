var natural = require('natural');
var path = require('path');
var async = require('async');
var fs = require('fs');
var _ = require("underscore");

var classifierPath = path.resolve('history.json');

module.exports = function(raw, callback) {

  // try each scheme
  async.map(["api", "classifier"], function(a, callback) {
    require("./"+path.join("schemes", a))(raw, function(err, resp) {
      if (err === null) {
        callback(null, resp);
      };
    });
  }, function(err, outputs) {

    // find the most relevant output
    // maxCount = _.min(_.pluck(outputs, 'ct'));
    // result = _.filter(outputs, function(n) {
    //   return n.ct === maxCount;
    // });
    // if (result.length) result = result[0];
    console.log(outputs);
    result = outputs[0];



    // add to classifier history
    natural.BayesClassifier.load(classifierPath, null, function(err, classifier) {

      // add to classifier our query
      classifier.addDocument(raw.toLowerCase(), JSON.stringify(result));

      // save classifier
      classifier.save(classifierPath, function(err, classifier) {
        callback(result);
      });

    });
  });
};

module.exports(process.argv.splice(2).join(' '), function(out) {
  console.log(out);
});
