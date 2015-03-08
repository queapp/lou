var natural = require('natural');
var path = require('path');
var async = require('async');
var chalk = require("chalk");
var _ = require("underscore");

module.exports = function(raw, callback) {

  // try each scheme
  async.map(["statics", "nlp", "dynamics"], function(a, callback) {
    mod = require("./"+path.join("schemes", a));
    mod(raw, function(err, resp) {
      console.log(chalk.red(a), err, resp)
      if (err) {
        // scheme failed us
        callback(err, null);
      } else {
        // worked!
        callback(err, resp);
      }
    });
  }, function(err, outputs) {
    // console.log(outputs);
    if (outputs && outputs.length) {
      response = _.compact(outputs)[0];
    } else {
      response = "NOTHING";
    }

    callback(response);
  });
};

module.exports(process.argv.splice(2).join(' '), function(out) {
  console.log(chalk.green(JSON.stringify(out, null, 2)));
});
