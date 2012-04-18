class App.Models.Scene extends Backbone.Model
  url: ->
    '/storybooks/' + this.get('storybook_id') + '/scenes/' + this.get('id')

  toJSON: ->
    { scene: _.clone this.attributes }

class App.Collections.ScenesCollection extends Backbone.Collection
  model: App.Models.Scene

  initialize: (models, options) ->
    this.storybook = options.storybook

  url: ->
    '/storybooks/' + this.storybook.get('id') + '/scenes.json'
