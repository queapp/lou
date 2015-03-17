var lou = require("../lou");

// well, this should tell jokes, but it doesn't yet.
module.exports = function(raw, prefs, callback) {

  switch(raw) {
    case "joke":
      // TODO restarty stuff here
      callback(null, {
        response: {
          text: "[Insert Joke Here]"
        },
        datapoints: {
          by: "statics.joker"
        }
      });
      break;

    default:
      callback(null, null);
  };
};
