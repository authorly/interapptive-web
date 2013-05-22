class App.Models.Sound extends Backbone.Model

  toString: ->
    @get('name')


class App.Collections.SoundsCollection extends Backbone.Collection
  model: App.Models.Sound

  initialize: (models, attributes) ->
    super
    @storybook = attributes.storybook


  baseUrl: ->
    @storybook.baseUrl() + "/sounds"


  url: ->
    @baseUrl() + '.json'
