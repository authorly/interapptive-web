class App.Models.Sound extends Backbone.Model
  url: ->
    '/storybooks/#{App.currentStorybook().get("id")}/scenes/#{App.currentScene().get("id")}/sounds.json'

class App.Collections.SoundsCollection extends Backbone.Collection
  model: App.Models.Sound

  url: ->
    return "/storybooks/" + App.currentStorybook().get('id') + "/sounds.json"
