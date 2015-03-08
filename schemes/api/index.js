var natural = require("natural");
var wordnet = new natural.WordNet();

var _ = require("underscore");
var chalk = require('chalk');
var async = require("async");

var api_imported = require("./apis");
var ApiDocs = require('./apidocs');
var api = new ApiDocs(api_imported);

// test against all apis
module.exports = function(raw, callback) {

  // look for the remote
  var phrase = raw.split(' ');
  api.searchFor(api_imported, phrase, function(err, remote) {
    if (err) throw err;

    // look for the resource in the remote
    api.searchFor(remote.resources, phrase, function(err, resource) {
      // console.log(resource);

      api.determineCRUDOperation(phrase, function(err, operation) {
        // api.evaluate(resource, resource.endpoints[operation].url, function(err, out) {

          // Got API!
          callback(null, {
            remote: remote,
            resource: resource,
            operation: operation
          });

        // });
      });
    });
  });

};
