#
# Used for showing sprites that could be added to currently
# active scene.
#
class App.Views.SpriteLibraryPalette extends Backbone.View
  template: JST['app/templates/palettes/sprite_library']
  className: 'sprites'
  tagName: 'ul'
  events:
    'click .icon-plus': '_addImages'


  initialize: ->
    @views = []


  render: ->
    @$el.html(@template())
    @_addAddSpriteIconTooltip()
    @


  openStorybook: (storybook) ->
    @storybook = storybook
    @collection = @storybook.images
    @_renderSpriteLibraryElements()


  _addImages: ->
    App.vent.trigger('show:imageLibrary')



  _addAddSpriteIconTooltip: ->
    @$('.icon-plus').tooltip
      title: "Add Images..."
      placement: 'right'


  _renderSpriteLibraryElements: ->
    @_renderSpriteLibraryElement(sprite) for sprite in @collection.models


  _renderSpriteLibraryElement: (sprite) ->
    view = new App.Views.SpriteLibraryElement(model: sprite)
    @views.push(view)
    @$el.append(view.render().el)
