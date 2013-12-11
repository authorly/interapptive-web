class Backbone.Form.editors.Image extends Backbone.Form.editors.Base

  tagName: 'div'

  events:
    'click .approve': '_approveImageClicked'

  # so Backbone Forms does not add one item to empty arrays, by default
  @isAsync: true


  initialize: ->
    super
    if @model?
      @collection = @model.storybook.images
      @setValue @model.get(@key)
    else
      @collection = @options.list.model.storybook.images
      @setValue @value


  render: ->
    @selector = @_initializeSelector()
    @approved = @_initializeApproved()
    @thumb =    @_initializeThumbDisplay()

    @$el.append @selector.$el, @thumb

    @listenTo @selector, 'select', @_imageSelected

    # because we need to use `isAsync`, we simulate a 'ready'
    window.setTimeout (=> @trigger 'readyToAdd', @), 0

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
    selectorEl = selector.render().$el
    selectorEl.prepend selectorEl.find('.selected-image')

    selector


  _initializeApproved: ->
    approved = $('<input type="button" class="approve btn btn-success" value="Use this screenshot"/>')
    @selector.$el.find('.selected-image').after approved

    approved.hide() unless @getValue()?

    approved


  _initializeThumbDisplay: ->
    image = @collection.get(@image_id)
    url = if image? then image.get('url') else ''
    thumb = $("<img class='thumb' src='#{url}'/>")

    thumb


  _imageSelected: (image) ->
      @setValue image?.id

      if image?
        @approved.show()
        @thumb.attr src: image.get('url')
      else
        @approved.hide()

      @trigger 'change', @


  _approveImageClicked: ->
    @selector.$el.hide()
    @thumb.show()
