class App.Models.Font extends Backbone.Model

  toString: ->
    @get('name')


class App.Collections.FontsCollection extends Backbone.Collection
  model: App.Models.Font

  initialize: (attributes, options) ->
    @storybook = options.storybook


  baseUrl: ->
    "/storybooks/" + @storybook.id + "/fonts"


  url: ->
    @baseUrl() + '.json'


  toSelectOptionGroup: (callback) =>
    onSuccess = (collection) ->
      callback(
        clx = collection.map (model) -> model.toSelectOption()
        clx.unshift {val: '', label: ''}
        clx
      )

    @fetch {success: (collection, response) -> onSuccess(collection) }
