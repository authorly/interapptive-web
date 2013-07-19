#
# The available assets.
#
class App.Views.AssetsLibrary extends Backbone.View
  template: JST['app/templates/palettes/sprite_library']
  className: 'sprites'
  tagName: 'ul'
  events:
    'click #sprite-message-library-link': '_openUploadModal'
    'click li': '_highlightSpriteElement'
    'click .icon-plus': '_addImage'


  initialize: ->
    @views = []


  render: ->
    @$el.html(@template())
    @_enableAddTooltip()
    @


  setCollection: (collection) ->
    @collection = collection
    @_renderSpriteLibraryElements()
    # TODO just add and/remove the corresponding view
    @collection.on('add remove', @_reRenderSpriteLibraryElements, @)


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
      # TODO keep the collection sorted
      sprites = _.sortBy(@collection.models, @_spriteFilenameComparator, @)
      @_renderSpriteLibraryElement(sprite) for sprite in sprites
    else
      @_addImageAbsenceMessage()


  _spriteFilenameComparator: (sprite) ->
    sprite.get('name')


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


  _highlightSpriteElement: (event) ->
    @$(event.currentTarget).toggleClass('selected').siblings().removeClass('selected')


  _enableAddTooltip: ->
    @$('.icon-plus').tooltip
      title: "Add Images..."
      placement: 'right'


  _addImage: ->
    App.vent.trigger('show:imageLibrary')
