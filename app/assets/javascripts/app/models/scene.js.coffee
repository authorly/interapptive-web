class App.Models.Scene extends Backbone.Model
  paramRoot: 'scene'
  
  url: ->
    '/storybooks/' + App.currentStorybook().get('id') + '/scenes'

class App.Collections.ScenesCollection extends Backbone.Collection
  model: App.Models.Scene

  initialize: (models, options) ->
    this.storybook_id = options.storybook_id

  url: ->
    '/storybooks/' + this.storybook_id + '/scenes.json'
