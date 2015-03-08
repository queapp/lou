## query in:

  - buffer into history

  - check through apis:

    ```javascript
    api.searchFor(api_imported, phrase, function(err, remote) {
      if (err) throw err;

      // look for the resource in the remote
      api.searchFor(remote.resources, phrase, function(err, resource) {
        // console.log(resource);

        api.determineCRUDOperation(phrase, function(err, operation) {
          api.evaluate(resource, resource.endpoints[operation].url, function(err, out) {
            console.log(resource.variables, out);
          });
        });
      });
    });
    ```

  - start checking nlp-supported stuff:
    - Que
    - Wolfram Alpha

  - check pre-programmed commands:
    - diagnosics
    - manual overrides

  - check classifier
