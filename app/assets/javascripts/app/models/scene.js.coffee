class App.Models.Scene extends Backbone.Model
  paramRoot: 'scene'
  
  url: ->
    base = '/storybooks/' + App.currentStorybook().get('id') + '/'
    return  (base + 'scenes.json') if @isNew()
    base + 'scenes/' + App.currentScene().get('id') + '.json'

class App.Collections.ScenesCollection extends Backbone.Collection
  model: App.Models.Scene

  initialize: (models, options) ->

    if options
      this.storybook_id = options.storybook_id

  url: ->
    '/storybooks/' + this.storybook_id + '/scenes.json'

  ordinalUpdateUrl: (sceneId) ->
    '/storybooks/' + this.storybook_id + '/scenes/sort.json'

  comparator: (scene) ->
    scene.get 'position'
