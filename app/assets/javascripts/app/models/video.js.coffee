class App.Models.Video extends Backbone.Model
  url: ->
    '/storybooks/#{App.currentStorybook().get("id")}/scenes/#{App.currentScene().get("id")}/videos.json'

  toString: ->
    @get('name')

  toSelectOption: ->
    val: @get('id')
    label: @toString()

class App.Collections.VideosCollection extends Backbone.Collection
  model: App.Models.Video

  url: ->
    return "/storybooks/" + App.currentStorybook().get('id') + "/videos.json"

  toSelectOptionGroup: (callback) =>
    onSuccess = (collection) ->
      callback(
        clx = collection.map (model) -> model.toSelectOption()
        clx.unshift {val: '', label: ''}
        clx
      )

    @fetch {success: (collection, response) -> onSuccess(collection) }
