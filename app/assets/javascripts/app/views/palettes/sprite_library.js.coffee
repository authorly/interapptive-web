#
# Used for showing sprites that could be added to currently
# active scene.
#
class App.Views.SpriteLibraryPalette extends Backbone.View
  className: 'sprites'
  tagName: 'ul'


  initialize: ->
    @views = []


  openStorybook: (storybook) ->
    @storybook = storybook
    @collection = @storybook.images
    @_renderSpriteLibraryElements()


  _renderSpriteLibraryElements: ->
    @_renderSpriteLibraryElement(sprite) for sprite in @collection.models


  _renderSpriteLibraryElement: (sprite) ->
    view = new App.Views.SpriteLibraryElement(model: sprite)
    @views.push(view)
    @$el.append(view.render().el)
