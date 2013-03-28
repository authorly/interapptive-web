#
# Used for showing sprites that could be added to currently
# active scene.
#
class App.Views.SpriteLibraryPalette extends Backbone.View
  className: 'sprites'
  tagName: 'ul'
  events:
    'click #sprite-message-library-link': '_openUploadModal'


  initialize: ->
    @views = []


  openStorybook: (storybook) ->
    @storybook = storybook
    @collection = @storybook.images
    @_renderSpriteLibraryElements()
    @collection.on('reset', @_reRenderSpriteLibraryElements, @)


  _reRenderSpriteLibraryElements: ->
    @_removeSpriteLibraryElements()
    @_renderSpriteLibraryElements()


  _removeSpriteLibraryElements: ->
    if @views.length is 0
      @_removeImageAbsenceMessage()
    view.remove() for view in @views
    @views = []


  _renderSpriteLibraryElements: ->
    if @collection.length > 0
      @_renderSpriteLibraryElement(sprite) for sprite in @collection.models
    else
      @_addImageAbsenceMessage()


  _renderSpriteLibraryElement: (sprite) ->
    view = new App.Views.SpriteLibraryElement(model: sprite)
    @views.push(view)
    @$el.append(view.render().el)


  _openUploadModal: (e) ->
    e.preventDefault()
    App.vent.trigger('show:imageLibrary')


  _removeImageAbsenceMessage: ->
    @$el.find('#sprite-library-message').remove()


  _addImageAbsenceMessage: ->
    $message = $('<div/>',
      id: 'sprite-library-message'
      html: 'No images have been uploaded, <a id="sprite-message-library-link" href="#">click here</a> to upload images to add to.'
    )
    @$el.append($message)
