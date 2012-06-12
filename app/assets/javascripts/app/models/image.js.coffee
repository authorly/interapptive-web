class App.Models.Image extends Backbone.Model
  paramRoot: 'image'

  url: ->
    '/images.json'

class App.Collections.ImagesCollection extends Backbone.Collection
  model: App.Models.Image

  url: ->
    '/images.json'
