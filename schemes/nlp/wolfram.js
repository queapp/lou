var lou = require("../lou");
var wa = require("wolfram-alpha");
var _ = require("underscore");
var natural = require("natural");

module.exports = function(raw, prefs, callback) {
  // callback(null, data) for success
  // callback(true, null) if data isn't relevant

  var formatOutput = function(raw, input) {
    str = raw.trim();

    if ( str.indexOf("nown") !== -1 || str.indexOf("adjective") !== -1 || str.indexOf("verb") !== -1) {
      // it's a definition
      str = _.map(str.split("\n"), function(row) {
        parts = row.split("|");

        // format into sentences.
        // do we have mutiple definitions?
        if ( parseInt(parts[0]) ) {
          parts[0] = natural.CountInflector.nth(parseInt(parts[0]));

          // put a word before the definition to introduce it better
          preword = "";
          if (parts[1].trim() === "verb") preword = "to ";

          // the definition
          return parts[0] + ", a " + parts[1].trim() + ", " + preword + parts[2];
        } else {
          return "a " + parts[0] + " - " + parts[1];
        };

      });
      str = str.join("; ");

    }

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
            text: formatOutput(phrase, raw)
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
