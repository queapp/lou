var _ = require("underscore"), request = require("request");

listItems = {
  "groceries": [
    "milk",
    "cookies",
    "eggs",
    "flour"
  ]
}

module.exports = [
  {
    name: "List Manager",
    tags: ["list"],
    resources: [
      {
        name: "List Objects",
        tags: ["list"],
        endpoints: {
          "create": {
            "url": "http://127.0.0.1:8000/list/create",
            "method": "post"
          },
          "read": {
            "url": "http://127.0.0.1:8000/list/{{name}}",
            "method": "get"
          },
          "update": {
            "url": "http://127.0.0.1:8000/list/{{name}}/{{payload}}",
            "method": "put"
          },
          "delete": {
            "url": "http://127.0.0.1:8000/list/{{name}}",
            "method": "delete"
          }
        }
      },
      {
        name: "List Items",
        tags: function(it) {
          list = _.flatten(_.map(listItems, function(v, k) {
            return listItems[k];
          }));
          return ["list", "new", "item", "add"].concat(list);
        },
        variables: {
          list_name: function(it, callback) {
            callback("listName");
          },
          name: function(it, callback) {
            callback("itemName")
          }
        },
        endpoints: {
          "create": {
            "url": "http://127.0.0.1:8000/list/{{list_name}}/{{name}}",
            "method": "post"
          },
          "read": {
            "url": "http://127.0.0.1:8000/list/{{list_name}}",
            "method": "get"
          },
          "update": {
            "url": "http://127.0.0.1:8000/list/{{list_name}}/{{name}}/{{payload}}",
            "method": "put"
          },
          "delete": {
            "url": "http://127.0.0.1:8000/list/{{list_name}}/{{name}}",
            "method": "delete"
          }
        }
      }
    ]
  }
]
