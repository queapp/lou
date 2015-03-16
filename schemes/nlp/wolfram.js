var lou = require("../lou");
var wa = require("wolfram-alpha");
var _ = require("underscore");

module.exports = function(raw, prefs, callback) {
  // callback(null, data) for success
  // callback(true, null) if data isn't relevant

  var formatOutput = function(raw) {
    str = raw.trim();

    if (str.indexOf('|') !== -1) {

      // 'table' formatting
      str = _.map(str.split("\n"), function(row) {
        parts = row.split('|')
        return _.initial(parts).join(";") + ": " + _.last(parts).trim();
      }).join("; ");

    };

    // return the formatted string
    return str.replace("\n", " ");
  };

  lou.persistant.read("wolfram.apikey", function(value) {
    var wolfram = wa.createClient(value, {});

    // do query
    wolfram.query(raw, function (err, result) {
      primary_pod = result.filter(function(i) {
        return i.primary || _.intersection(i.title.toLowerCase().split(' '), ["information", "result"]).length > 0
      });
      if (primary_pod.length) {
        phrase = primary_pod[0].subpods.map(function(i) { return i.text; }).join(' ');
        callback(err, {
          response: {
            text: formatOutput(phrase)
          },
          datapoints: {
            by: "nlp.wolfram"
          }
        });
      } else {
        // data isn't very good
        callback(true, null);
      }
    });

  });
};
