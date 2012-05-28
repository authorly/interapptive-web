class App.Models.Attribute extends Backbone.Model
  paramRoot: 'attribute'

  schema:
    value:
      type: ->
        this.get('attributeDefinition').get('type')
      title: ->
        this.get('attributeDefinition').get('name')
      validators: ['required']
