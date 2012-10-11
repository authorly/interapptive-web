class App.Models.Video extends Backbone.Model
  url: ->
    '/storybooks/#{App.currentStorybook().get("id")}/scenes/#{App.currentScene().get("id")}/videos.json'

class App.Collections.VideosCollection extends Backbone.Collection
  model: App.Models.Video

  url: ->
    return "/storybooks/" + App.currentStorybook().get('id') + "/videos.json"
