class App.Models.Action extends Backbone.Model
  paramRoot: 'action'

  url: ->
    if @isNew
      '/scenes/' + App.currentScene().get('id') + '/actions.json'
    else
      '/scenes/' + App.currentScene().get('id') + '/actions/' + this.get('id') + '.json'

class App.Collections.ActionsCollection
  model: App.Models.Action
  
  url: ->
    '/scenes/' + App.currentScene().get('id') + '/actions.json'

class App.Models.ActionDefinition extends Backbone.Model
  paramRoot: 'action_definition'

class App.Collections.ActionDefinitionsCollection extends Backbone.Collection
  model: App.Models.ActionDefinition
  url: '/actions/definitions.json'
