_ = require("underscore")
request = require("request")
listItems = groceries: [
  "milk"
  "cookies"
  "eggs"
  "flour"
]
module.exports = [
  name: "List Manager"
  tags: ["list"]
  resources: [
    {
      name: "List Objects"
      tags: ["list"]
      endpoints:
        create:
          url: "http://127.0.0.1:8000/list/create"
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
    {
      name: "List Items"
      tags: (it) ->
        list = _.flatten(_.map(listItems, (v, k) ->
          listItems[k]
        ))
        [
          "list"
          "new"
          "item"
          "add"
        ].concat list

      variables:
        list_name: (it, callback) ->
          callback "listName"
          return

        name: (it, callback) ->
          callback "itemName"
          return

      endpoints:
        create:
          url: "http://127.0.0.1:8000/list/{{list_name}}/{{name}}"
          method: "post"

        read:
          url: "http://127.0.0.1:8000/list/{{list_name}}"
          method: "get"

        update:
          url: "http://127.0.0.1:8000/list/{{list_name}}/{{name}}/{{payload}}"
          method: "put"

        delete:
          url: "http://127.0.0.1:8000/list/{{list_name}}/{{name}}"
          method: "delete"
    }
  ]
]
