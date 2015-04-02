natural = require("natural")
wordnet = new natural.WordNet()
_ = require("underscore")
chalk = require("chalk")
async = require("async")
request = require("request")

lou = require "../lou"
api_imported = require("./apis")
ApiDocs = require("./apidocs")
api = new ApiDocs(api_imported)

# test against all apis
module.exports = (raw, prefs, callback) ->

  # look for the remote
  phrase = raw.split(" ")
  api.searchFor api_imported, phrase, (err, remote) ->
    throw err if err

    # look for the resource in the remote
    api.searchFor remote.resources, phrase, (err, resource) ->

      # console.log(resource);
      api.determineCRUDOperation phrase, (err, operation) ->

        # api.evaluate(resource, resource.endpoints[operation].url, function(err, out) {
        # console.log(remote, resource, operation)
        # Got API!
        if resource.endpoints[operation]
          request resource.endpoints[operation], (err, resp, body) ->

            # console.log(body)
            lou.find.directObject raw, (dos) ->
              callback null,

                # response: {
                #   remote: remote,
                #   resource: resource,
                #   operation: operation
                # },
                # response: resource.endpoints[operation],
                response:
                  text: body

                datapoints:
                  by: "dynamics." + remote.name + "." + resource.name + "." + operation
                  directObjects: dos

            return
        else
          callback true, null

        return

      return

    return

  return

# });
