var _ = require("underscore");

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
            "url": "127.0.0.1:8000/list/create",
            "method": "post"
          },
          "read": {
            "url": "127.0.0.1:8000/list/{{name}}",
            "method": "get"
          },
          "update": {
            "url": "127.0.0.1:8000/list/{{name}}/{{payload}}",
            "method": "put"
          },
          "delete": {
            "url": "127.0.0.1:8000/list/{{name}}",
            "method": "delete"
          }
        }
      },
      {
        name: "List Items",
        tags: function(it) {
          list = _.flatten(_.map(listItems, function(v, k){
            return listItems[k];
          }));
          return ["list", "new", "item", "add"].concat(list);
        },
        variables: {
          list_name: function(it, callback) {
            callback("listName");
          }
        },
        endpoints: {
          "create": {
            "url": "127.0.0.1:8000/list/{{list_name}}/{{name}}",
            "method": "post"
          },
          "read": {
            "url": "127.0.0.1:8000/list/{{list_name}}",
            "method": "get"
          },
          "update": {
            "url": "127.0.0.1:8000/list/{{list_name}}/{{name}}/{{payload}}",
            "method": "put"
          },
          "delete": {
            "url": "127.0.0.1:8000/list/{{list_name}}/{{name}}",
            "method": "delete"
          }
        }
      }
    ]
  }
]
