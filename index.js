var natural = require('natural');
var path = require('path');
var async = require('async');
var chalk = require("chalk");
var _ = require("underscore");

// create express app and parse request body
var app = require("express")();
var bodyParser = require('body-parser');
app.use(bodyParser.json());

// === session datapoints ===
var data = [];
durationBetweenSessions = 30 * 1000;


var query = module.exports = function(raw, prefs, callback) {
  prefs = prefs || {};
  console.log("---");

  // try each scheme, one at a time
  eachScheme = function(raw, prefs, callback) {
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

  // try the last handler that was invoked
  if (prefs.session.length) {
    // where is the handler, exactly?
    lastHandler = _.last(prefs.session).by;
    handlerPath = ["schemes"].concat(lastHandler.split("."));
    try {
      mod = require( "./"+path.join.apply(path, handlerPath) );
    } catch(e) {} finally {
      // call it
      mod && mod(raw, prefs, function(err, resp) {
        console.log(chalk.red("previous"), chalk.yellow(lastHandler), resp);
        if (resp && resp.response) {
          // worked!
          callback(resp);
        } else {
          // scheme failed us
          eachScheme(raw, prefs, callback);
        }
      });
    };
  } else {
    eachScheme(raw, prefs, callback);
  }
};


// === query-er ===
// Let the user perform a query on lou.
doSearch = function(req, res) {
  var msg = req.query.q || req.query.query;
  res.header({"content-type": "application/json"});
  if (msg) {
    query(msg, {
      session: data,
      body: req.body
    }, function(out) {
      console.log(chalk.yellow("out"), out.response);

      // add datapoints
      if (out.datapoints) {
        out.datapoints.timestamp = (new Date()).getTime();

        if (data.length) {
          data.push(out.datapoints);
        } else {
          data = [out.datapoints];
        }
      }

      // and, send off the response
      res.send(JSON.stringify(out));
    });
  } else {
    res.send(JSON.stringify({"error": "No Query Specified. Use parameter q or query."}))
  }
};
app.post("/search", doSearch);
app.get("/search", doSearch)

// === datapoints ===
// Debug endpoint to show all the current datapoints.
app.get("/datapoints", function(req, res) {
  res.send(JSON.stringify(data, null, 2));
});

// === session garbage collector ===
// if the last query is over `durationBetweenSessions` old,
// terminate the current session. Most likely, the user has
// moved on by now, anyway.

// setInterval(function() {
//   now = (new Date()).getTime();
//   pt = _.last(data);
//   if ( pt && pt.timestamp + durationBetweenSessions > now) {
//     data = [];
//     console.log(chalk.blue("=> Current session has ended."))
//   }
// }, durationBetweenSessions);

// start listening for connections.
port = process.env.PORT || 8001;
console.log(chalk.blue("=> The magic is at :"+port))
app.listen(port);
