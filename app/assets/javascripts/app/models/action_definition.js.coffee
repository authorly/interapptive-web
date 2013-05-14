class App.Models.ActionDefinition extends Backbone.Model

class App.Collections.ActionDefinitionsCollection extends Backbone.Collection
  model: App.Models.ActionDefinition
  url: '/actions/definitions.json'
