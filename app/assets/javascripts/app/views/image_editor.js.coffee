class Backbone.Form.editors.Image extends Backbone.Form.editors.Base

  tagName: 'div'

  events:
    'click .approve': '_approveImageClicked'
    'click .reject':  '_rejectImageClicked'
    'click .thumb':   '_changeImageClicked'

  # so Backbone Forms does not add one item to empty arrays, by default
  @isAsync: true


  initialize: ->
    super
    if @model?
      @collection = @model.storybook?.images || @model.images()
      @setValue @model.get(@key)
    else
      @collection = @options.list.model.storybook.images
      @setValue @value


  render: ->
    @selector = @_initializeSelector()
    @buttons =  @_initializeButtons()
    @thumb =    @_initializeThumbDisplay()

    @$el.append @selector.$el, @thumb
    @selector.$el.find('.selected-image').after @buttons

    @listenTo @selector, 'select', @_imageSelected

    # because we need to use `isAsync`, we simulate a 'ready'
    window.setTimeout (=> @trigger 'readyToAdd', @), 0

    image = @_image()
    @_imageSelected(image)
    if image?
      @_approveImageClicked()
    else
      @_changeImageClicked()

    @


  getValue: ->
    @image_id


  setValue: (value) ->
    @image_id = value


  _initializeSelector: ->
    selector = new App.Views.ImageSelector
      image: @collection.get @getValue()
      collection: @collection
      selectedImageViewClass: 'SelectedSprite'
      className: 'selector'
      defaultImage: @_default()
    selectorEl = selector.render().$el
    selectorEl.prepend selectorEl.find('.selected-image')

    selector


  _initializeButtons: ->
    name = @options.schema.name || 'image'
    buttons = $("<div><input type='button' class='approve btn btn-success' value='Use this #{name}'/><input type='button' class='reject btn btn-cancel' value='Remove'/></div>")

    buttons.hide() unless @_image()?

    buttons


  _initializeThumbDisplay: ->
    image = @_image()
    url = if image? then image.get('url') else ''
    thumb = $("<a href='#'><img class='thumb' src='#{url}'/></a>")

    thumb


  _default: ->
    @options.schema.default


  _image: ->
    @collection.get(@getValue()) || @_default()


  _imageSelected: (image) ->
      @setValue image?.id

      if image?
        @buttons.show()
        reject = @buttons.find('.reject')
        if image == @_default()
          reject.hide()
        else
          reject.show()
        @thumb.find('img').attr src: image.get('url')
      else
        @buttons.hide()

      @trigger 'change', @


  _approveImageClicked: ->
    @selector.$el.hide()
    @thumb.show()


  _rejectImageClicked: ->
    @selector.setImage @_default()


  _changeImageClicked: ->
    @selector.$el.show()
    @thumb.hide()
