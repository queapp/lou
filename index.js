var natural = require('natural');
var path = require('path');
var async = require('async');
var chalk = require("chalk");
var _ = require("underscore");

var app = require("express")();

var query = module.exports = function(raw, prefs, callback) {
  prefs = prefs || {};

  // try each scheme
  async.mapSeries(["statics", "nlp", "dynamics"], function(a, callback) {
    mod = require("./"+path.join("schemes", a));
    mod(raw, prefs, function(err, resp) {
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

// === session datapoints ===
var data = [];
durationBetweenSessions = 30 * 1000;

// === query-er ===
// Let the user perform a query on lou.
app.get("/search", function(req, res) {
  var msg = req.query.q || req.query.query;
  res.header({"content-type": "application/json"});
  if (msg) {
    query(msg, {
      session: data
    }, function(out) {

      // add datapoints
      if (out.datapoints) {
        out.datapoints.timestamp = (new Date()).getTime();

        if (data.length) {
          _.last(data).push(out.datapoints);
        } else {
          data = [[out.datapoints]];
        }
      }

      // and, send off the response
      res.send(JSON.stringify(out));
    });
  } else {
    res.send(JSON.stringify({"error": "No Query Specified. Use parameter q or query."}))
  }
});

// === datapoints ===
// Debug endpoint to show all the current datapoints.
app.get("/datapoints", function(req, res) {
  res.send(JSON.stringify(data, null, 2));
});

// === session garbage collector ===
// if the last query is over `durationBetweenSessions` old,
// terminate the current session. Most likely, the user has
// moved on by now, anyway.
setInterval(function() {
  now = (new Date()).getTime();
  pt = _.last(_.last(data));
  if ( pt && pt.timestamp + durationBetweenSessions > now) {
    data = [];
    console.log(chalk.blue("=> Current session has ended."))
  }
}, 5000);

// start listening for connections.
port = process.env.PORT || 8001;
console.log(chalk.blue("=> The magic is at :"+port))
app.listen(port);
