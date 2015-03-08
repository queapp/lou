var lou = require("../../");

// power-stuff: like restart, stop/start, etc...
module.exports = function(raw, callback) {

  switch(raw) {
    case "restart":
      // TODO restarty stuff here
      callback(null, {
        action: "lou.power.restart",
        msg: "Lou is restarting - please wait..."
      });
      break;

    default:
      callback(null, null);
  };
};
