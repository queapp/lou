var fs = require("fs"), async = require("async");

module.exports = {

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

  }

};
