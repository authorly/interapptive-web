class App.Models.Action extends Backbone.Model
  paramRoot: 'action'

class App.Models.ActionDefinition extends Backbone.Model
  paramRoot: 'action_definition'

class App.Collections.ActionDefinitionsCollection extends Backbone.Collection
  model: App.Models.ActionDefinition
  url: '/actions/definitions.json'
