class App.Models.Image extends Backbone.Model
  url: ->
    '/storybooks/#{App.currentStorybook().get("id")}/scenes/#{App.currentScene().get("id")}/images.json'

  toString: ->
    @get('name')

class App.Collections.ImagesCollection extends Backbone.Collection
  model: App.Models.Image

  url: ->
    return "/storybooks/" + App.currentStorybook().get('id') + "/images.json"
