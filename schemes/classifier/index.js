var natural = require('natural');
var path = require('path');
var fs = require('fs');

var classifierPath = path.resolve('history.json');

module.exports = function(raw, callback) {

  fs.exists(classifierPath, function(exists) {

    // create history if it doesn't already exist
    if (!exists) {
      classifier = new natural.BayesClassifier();
      classifier.addDocument(" ", "{}");
      classifier.save(classifierPath, function(err, c) {
        console.log(err);
      });
    };

    // open classifier
    natural.BayesClassifier.load(classifierPath, null, function(err, classifier) {
      if (err) {
        callback(err);
        return;
      };

      // train
      classifier.train();

      // classify
      result = classifier.classify("abc");

      // add to classifier our example
      classifier.addDocument(raw.toLowerCase(), result);

      // save classifier
      classifier.save(classifierPath, function(err, classifier) {
        callback(err, JSON.parse(result));
      });

    });
  });
};

// test classifier
// module.exports("weather", function(err, data) {
//   console.log(err, data);
// });
