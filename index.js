var natural = require('natural');
var path = require('path');
var async = require('async');
var chalk = require("chalk");
var _ = require("underscore");

var app = require("express")();

var query = module.exports = function(raw, callback) {

  // try each scheme
  async.mapSeries(["statics", "nlp", "dynamics"], function(a, callback) {
    mod = require("./"+path.join("schemes", a));
    mod(raw, function(err, resp) {
      console.log(chalk.red(a), resp)
      if (resp && resp.response) {
        // worked!
        callback(true, resp);
      } else {
        // scheme failed us
        callback(err, null);
      }
    });
  }, function(err, outputs) {
    // console.log("OUTPUTS", outputs);
    if (outputs && outputs.length) {
      response = _.compact(outputs)[0];
    } else {
      response = "NOTHING";
    }

    callback(response);
  });
};

// datapoints for sessions
var data = [];

// do a query
app.get("/search", function(req, res) {
  var msg = req.query.q || req.query.query;
  res.header({"content-type": "application/json"});
  if (msg) {
    query(msg, function(out) {

      // add datapoints
      if (data.length && out.datapoints) {
        _.last(data).push(out.datapoints);
      } else {
        data = [[out.datapoints]];
      }

      // and, send off the response
      res.send(JSON.stringify(out));
    });
  } else {
    res.send(JSON.stringify({"error": "No Query Specified. Use parameter q or query."}))
  }
});

// start listening
port = process.env.PORT || 8001;
console.log(chalk.blue("=> The magic is at :"+port))
app.listen(port);
