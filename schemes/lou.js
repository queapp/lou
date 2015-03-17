var fs = require("fs"), async = require("async");

var lou = module.exports = {

  persistant: {
    location: "session/persistant.json",
    cache: {},

    // write to cache and file
    write: function(name, value, callback) {
      this.cache[name] = value;
      fs.writeFile(
        this.location,
        JSON.stringify(this.cache, null, 2),
        function(err, out) {
          callback && callback(err, out);
      });
    },

    // read from cache
    read: function(name, callback) {
      if (typeof this.cache === "object" && Object.keys(this.cache).length !== 0) {
        callback(this.cache[name]);
      } else {
        this.generateCache(function(cache) {
          callback(cache[name]);
        });
      }
    },

    readAll: function(names, callback) {
      var root = this;
      async.map(names, function(n, c) {
        root.read(n, function(v) { c(null, v); });
      }, function(err, all) {
        callback.apply(this, all);
      });
    },

    // regenerate cache
    generateCache: function(callback) {
      fs.readFile(this.location, function(err, data) {
        this.cache = JSON.parse(data.toString());
        callback && callback(cache);
      });
    }

  },

  location: {

    // get current location in lat and lng of a user
    getCurrentCoords: function(prefs, callback) {
      if (prefs.body.location) {
        // use client location
        callback({
          lat: prefs.body.location.lat,
          lng: prefs.body.location.lng
        });
      } else {
        lou.persistant.read("location.gps", function(location) {
          if (location) {
            // use stored server location
            callback({
              lat: location.lat,
              lng: location.lng
            });
          } else {
            // well, crap, we don't know where we are.
            callback({lat: null, lng: null});
          }
        });
      }
    }



  },

  // word lists for natural language stuff
  words: {
    pronowns: {
      first: {
        sing: ["i", "my", "mine"],
        plur: ["we", "our", "ours"]
      },
      second: {
        sing: ["you", "your"],
        plur: ["you", "your"]
      },
      third: {
        sing: ["he", "she", "it", "him", "her", "his", "hers", "its"],
        plur: ["we", "our", "ours"]
      }
    }
  }

};
