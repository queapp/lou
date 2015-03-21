var natural = require("natural");
var wordnet = new natural.WordNet();

var _ = require("underscore");
var chalk = require('chalk');
var async = require("async");
var request = require("request");

var api_imported = require("./apis");
var ApiDocs = require('./apidocs');
var api = new ApiDocs(api_imported);

// test against all apis
module.exports = function(raw, prefs, callback) {

  // look for the remote
  var phrase = raw.split(' ');
  api.searchFor(api_imported, phrase, function(err, remote) {
    if (err) throw err;

    // look for the resource in the remote
    api.searchFor(remote.resources, phrase, function(err, resource) {
      // console.log(resource);

      api.determineCRUDOperation(phrase, function(err, operation) {
        // api.evaluate(resource, resource.endpoints[operation].url, function(err, out) {
          // console.log(remote, resource, operation)
          // Got API!

          request(resource.endpoints[operation], function(err, resp, body) {
            // console.log(body)
            callback(null, {
              // response: {
              //   remote: remote,
              //   resource: resource,
              //   operation: operation
              // },
              // response: resource.endpoints[operation],
              response: {
                text: body
              },
              datapoints: {
                by: "dynamics."+remote.name+"."+resource.name+"."+operation
              }
            });
          });


        // });
      });
    });
  });

};
