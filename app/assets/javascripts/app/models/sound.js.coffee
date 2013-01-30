class App.Models.Sound extends Backbone.Model
  url: ->
    '/storybooks/' + App.currentSelection.get('storybook').get("id") + '/scenes/' + App.currentSelection.get('scene').get("id") + '/sounds.json'

  toString: ->
    @get('name')

  toSelectOption: =>
    val: @get('id')
    label: @toString()

class App.Collections.SoundsCollection extends Backbone.Collection
  model: App.Models.Sound

  initialize: (models, attributes) ->
    super
    @storybook = attributes.storybook


  url: ->
    "/storybooks/" + App.currentSelection.get('storybook').get('id') + "/sounds.json"

  toSelectOptionGroup: (callback) =>
    onSuccess = (collection) ->
      callback(
        clx = collection.map (model) -> model.toSelectOption()
        clx.unshift {val: '', label: ''}
        clx
      )

    @fetch {success: (collection, response) -> onSuccess(collection) }
