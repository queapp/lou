var lou = require("../../");

// power-stuff: like restart, stop/start, etc...
module.exports = function(raw, callback) {

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
