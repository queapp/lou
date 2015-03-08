var async = require("async"), _ = require("underscore");
var reqs = [
  require("./que")
];

// run all nlp stuff
module.exports = function(raw, callback) {
  async.map(reqs, function(r, cb) {
    r(raw, cb);
  }, function(err, all) {
    if (err) {
      callback(true, null);
    } else {
      match = _.compact(all)[0];
      callback(err || null, match || null);
    }
  });
};
