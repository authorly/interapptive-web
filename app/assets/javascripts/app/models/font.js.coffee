class App.Models.Font extends Backbone.Model
  url: ->
    '/storybooks/#{App.currentStorybook().get("id")}/scenes/#{App.currentScene().get("id")}/fonts.json'

  toString: ->
    @get('name')

class App.Collections.FontsCollection extends Backbone.Collection
  model: App.Models.Font

  url: ->
    "/storybooks/" + App.currentStorybook().get('id') + "/fonts.json"

  toSelectOptionGroup: (callback) =>
    onSuccess = (collection) ->
      callback(
        clx = collection.map (model) -> model.toSelectOption()
        clx.unshift {val: '', label: ''}
        clx
      )

    @fetch {success: (collection, response) -> onSuccess(collection) }
