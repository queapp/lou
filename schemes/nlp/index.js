var async = require("async"), _ = require("underscore");
var reqs = [
  require("./weather"),
  require("./que"),
  require("./wolfram")
];

// run all nlp stuff
module.exports = function(raw, prefs, callback) {
  async.mapSeries(reqs, function(r, cb) {
    r(raw, prefs, function(err, data) {
      // do we have a decent response?
      if (!err && data && data.response) {
        // cool, we're done.
        cb(true, data);
      } else {
        cb(null, data);
      };
    });
  }, function(err, all) {
    if (all.length == 0) {
      callback(true, null);
    } else {
      match = _.compact(all)[0];
      callback(null, match || null);
    }
  });
};
