class App.Models.Action extends Backbone.Model
  paramRoot: 'action'

  schema:
    attribute:
      type: 'NestedModel'
      model: App.Models.Attribute
