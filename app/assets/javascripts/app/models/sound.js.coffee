class App.Models.Sound extends Backbone.Model
  url: ->
    '/storybooks/#{App.currentStorybook().get("id")}/scenes/#{App.currentScene().get("id")}/sounds.json'

  toString: ->
    @get('name')

  toSelectOption: =>
    val: @get('id')
    label: @toString()

class App.Collections.SoundsCollection extends Backbone.Collection
  model: App.Models.Sound

  url: ->
    return "/storybooks/" + App.currentStorybook().get('id') + "/sounds.json"

  toSelectOptionGroup: (callback) =>
    onSuccess = (collection) ->
      callback(
        clx = collection.map (model) -> model.toSelectOption()
        clx.unshift {val: '', label: ''}
        clx
      )

    @fetch {success: (collection, response) -> onSuccess(collection) }
