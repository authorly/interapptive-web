class App.Models.Video extends Backbone.Model

  toString: ->
    @get('name')


class App.Collections.VideosCollection extends Backbone.Collection
  model: App.Models.Video

  initialize: (models, attributes) ->
    super
    @storybook = attributes.storybook


  baseUrl: ->
    @storybook.baseUrl() + "/videos"


  url: ->
    @baseUrl() + '.json'
