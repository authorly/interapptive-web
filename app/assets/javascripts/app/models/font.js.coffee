class App.Models.Font extends Backbone.Model

  toString: ->
    @get('name')


class App.Collections.FontsCollection extends Backbone.Collection
  model: App.Models.Font

  initialize: (models, attributes) ->
    super
    @storybook = attributes.storybook


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


  comparator: (model) ->
    model.get('name')