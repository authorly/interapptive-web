class App.Models.Video extends Backbone.Model
  url: ->
    '/storybooks/' + App.currentSelection.get('storybook').get("id") + '/scenes/' + App.currentSelection.get('scene').get("id") + '/videos.json'

  toString: ->
    @get('name')

  toSelectOption: ->
    val: @get('id')
    label: @toString()

class App.Collections.VideosCollection extends Backbone.Collection
  model: App.Models.Video

  initialize: (models, attributes) ->
    super
    @storybook = attributes.storybook


  url: ->
    @baseUrl() + '.json'


  baseUrl: ->
    "/storybooks/" + @storybook.id + "/videos"


  toSelectOptionGroup: (callback) =>
    onSuccess = (collection) ->
      callback(
        clx = collection.map (model) -> model.toSelectOption()
        clx.unshift {val: '', label: ''}
        clx
      )

    @fetch {success: (collection, response) -> onSuccess(collection) }
