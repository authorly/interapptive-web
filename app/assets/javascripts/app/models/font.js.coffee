class App.Models.Font extends Backbone.Model

  toString: ->
    @get('name')


  isSystem: ->
    @get('asset_type') is 'system'


class App.Collections.FontsCollection extends Backbone.Collection
  model: App.Models.Font

  initialize: (models, attributes) ->
    super
    @storybook = attributes.storybook


  baseUrl: ->
    @storybook.baseUrl() + "/fonts"


  url: ->
    @baseUrl() + '.json'


  comparator: (model) ->
    model.get('name')
