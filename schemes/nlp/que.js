var request = require("request");
var lou = require("../lou");
var _ = require("underscore");

module.exports = function(raw, prefs, callback) {
  // callback(null, data) for success
  // callback(true, null) if data isn't relevant

  // read hostname and api key
  lou.persistant.readAll(["que.apikey", "que.hostname"], function(key, host) {
    if (!key || !host) {
      callback(true, null);
      return;
    };

    // make the query
    request({
      url: host + "/natural/query",
      method: "post",
      json: true,
      body: {
        data: raw,
        assumptions: {
          thing: (_.last(prefs.session) || {}).thing,
          operation: (_.last(prefs.session) || {}).operation,
          data: (_.last(prefs.session) || {}).data
        }
      },
      headers: {
        'content-type' : 'application/json',
        'authentication': key
      },
    }, function(error, response, body) {
      if (typeof body == "string" && body.trim().toLowerCase() == "not authenticated") {
        // isn't authenticated
        callback(true, null);
      } else if (typeof body != "object" || body.status.toUpperCase() == "ERR") {
        // no relevant data returned
        callback(null, null);
      } else {
        // relevant data returned
        callback(null, {
          response: {text: body.msg || body},
          datapoints: {
            by: "nlp.que",

            thing: body.thing,
            operation: body.operation,
            data: body.data
          }
        });
      }
    });

  });
};
