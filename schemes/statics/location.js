var lou = require("../lou");
var _ = require("underscore");

module.exports = function(raw, prefs, callback) {

  // words = raw.split(" ");
  // options = ["where", "what"]
  // options = options.concat(lou.words.pronowns.first.sing);
  // options = options.concat(lou.words.pronowns.first.plur);
  // matches = _.intersection(words, options);

  if (raw.indexOf("location") !== -1) {

    // get current coordinates
    lou.location.getCurrentCoords(prefs, function(location) {
      callback(null, {
        response: {
          text: "You are currently at "+location.lat+", "+location.lng
        },
        datapoints: {
          by: "statics.location"
        }
      });
    });

  }

  callback(true, null);
};
