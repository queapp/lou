var lou = require("../lou");
var wa = require("wolfram-alpha");

module.exports = function(raw, callback) {
  // callback(null, data) for success
  // callback(true, null) if data isn't relevant

  lou.persistant.read("wolfram.apikey", function(value) {
    var wolfram = wa.createClient(value, {});

    // do query
    wolfram.query(raw, function (err, result) {
      primary_pod = result.filter(function(i) { return i.primary; })
      if (primary_pod.length) {
        phrase = primary_pod[0].subpods.map(function(i) { return i.text; }).join(' ');
        callback(err, phrase.trim());
      } else {
        // data isn't very good
        callback(true, null);
      }
    });

  });
};
