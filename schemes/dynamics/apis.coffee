_ = require("underscore")
request = require("request")
listItems = groceries: [
  "milk"
  "cookies"
  "eggs"
  "flour"
]
module.exports = [
  name: "Twitter"
  tags: ["tweet", "twitter"]
  resources: [
    {
      name: "Tweets"
      tags: ["tweet", "tweets"]
      endpoints:
        create:
          url: "http://127.0.0.1:8000/newtweet/{{text}}"
          method: "post"

        read:
          url: "http://127.0.0.1:8000/list/{{name}}"
          method: "get"

        update:
          url: "http://127.0.0.1:8000/list/{{name}}/{{payload}}"
          method: "put"

        delete:
          url: "http://127.0.0.1:8000/list/{{name}}"
          method: "delete"
    }
  ]
]
