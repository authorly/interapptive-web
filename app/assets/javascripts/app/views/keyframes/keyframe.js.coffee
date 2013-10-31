class App.Views.Keyframe extends Backbone.View
  DELETE_KEYFRAME_MSG:
    '\nYou are about to delete a keyframe.\n\n\nAre you sure you want to continue?\n'

  template: JST["app/templates/keyframes/keyframe"]
  tagName: 'li'

  events:
    'click  .main':                       '_clicked'
    'click  .delete-keyframe':            '_deleteClicked'
    'change [name="animation-duration"]': '_animationDurationChanged'
    'click  .keyframe-configuration':     '_configurationClicked'


  initialize: ->
    @listenTo App.currentSelection, 'change:keyframe', @_activeKeyframeChanged
    @listenTo @model, 'change:animation_duration',  @animationDurationChanged
    @listenTo @model, 'invalid:animation_duration', @invalidAnimationDurationEntered
    @listenTo @model.widgets,        'add remove change:position change:scale change:radius',  @widgetsChanged
    @listenTo @model.scene.widgets,  '           change:position change:scale change:z_order change:disabled change:image_id', @widgetsChanged


  remove: ->
    @stopListening()
    super


  render: ->
    @$el.html(@template(keyframe: @model)).attr('data-id', @model.id)
    if @model.isAnimation()
      @$el.attr('data-is_animation', '1').addClass('animation')
    if @model.preview.isNew()
      @renderPreview()

    @


  _clicked: ->
    App.currentSelection.set
      keyframe: @model


  _deleteClicked: (event) =>
    event.stopPropagation()
    return if @$el.hasClass('disabled')

    if confirm(@DELETE_KEYFRAME_MSG)
      collection = @model.collection
      @model.destroy
        success: =>
          mixpanel.track "Deleted keyframe"
          collection.remove(@model)


  _animationDurationChanged: (event) ->
    @model.set
      animation_duration: Number($(event.currentTarget).val())


  updateAnimationDuration: (event) ->
    @model.set
      animation_duration: Number($(event.currentTarget).val())


  widgetsChanged: (model) ->
    if model instanceof App.Models.HotspotWidget or
       model instanceof App.Models.SpriteOrientation or
       model instanceof App.Models.ImageWidget
      @renderPreview()


  _configurationClicked: ->
    view = new App.Views.KeyframeSettings
      model: @model
    App.modalWithView(view: view).show()


  _activeKeyframeChanged: (__, keyframe) ->
    klass = 'active'
    if keyframe == @model
      @$el.addClass klass
    else
      @$el.removeClass klass


  renderPreview: =>
    images = _.map @_allWidgets(), (widget) =>
      App.Lib.ImageCache.instance().get @_getImageWidget(widget).image().get('url')
    # make sure that, if there is an image, we pass an array with at least 2 elements
    # to make jquery invoke the callback with an array of results (even if there is
    # one required image)
    images.push [null, null]

    $.when.apply($, images).then @_renderPreview


  _renderPreview: (images...) =>
    @_ensureCanvasCreated()

    @previewCtx.clearRect 0, 0, 150, 112
    @_renderImages(images)
    @_renderHotspots()

    @_exportPreview()


  _ensureCanvasCreated: ->
    return if @$('canvas').length > 0

    @$('.main').html '<canvas width="150" height="112"/>'
    @previewCanvas = @$('.main canvas')[0]
    @previewHeight = @previewCanvas.height
    @previewCtx = @previewCanvas.getContext('2d')
    @previewCtx.fillStyle = 'rgba(174, 204, 246, 0.66)'
    @previewScale = @previewCanvas.width * 1.0 / App.Config.dimensions.width


  _renderHotspots: ->
    for widget in @model.hotspotWidgets()
      position = widget.get('position')

      @previewCtx.beginPath()
      @previewCtx.arc position.x * @previewScale,
                      @previewHeight - position.y * @previewScale,
                      widget.get('radius') * @previewScale,
                      0, 360
      @previewCtx.fill()


  _renderImages: (imageLoadResults) ->
    imageCache = _.object(imageLoadResults)
    widgets = @_allWidgets().sort (w1, w2) =>
      @_getImageWidget(w1).get('z_order') - @_getImageWidget(w2).get('z_order')

    _.each widgets, (widget) =>
      position = widget.get('position')
      scale = widget.get('scale')
      img = imageCache[@_getImageWidget(widget).image().get('url')]

      # draw the image, scaled down, using `drawImage(image, dx, dy, dw, dh)
      # the scale is compound - the scale of the image, and the scale of the
      # preview compared to the canvas
      # images are center-anchored, so half of their width/height is substracted
      # to get the top-left corner, required for `drawImage`
      @previewCtx.drawImage img,
        (position.x - img.width * scale/2) * @previewScale,
        @previewHeight - (position.y + img.height * scale/2) * @previewScale,
        img.width  * scale * @previewScale,
        img.height * scale * @previewScale


  _exportPreview: ->
    image = Canvas2Image.saveAsPNG @previewCanvas, true
    @model.setPreviewDataUrl image.src


  _allWidgets: ->
    mainMenuButtons = @model.scene.widgets.byClass(App.Models.ButtonWidget)
    [].concat @model.widgets.byClass(App.Models.SpriteOrientation),
              _.reject(mainMenuButtons, (button) -> button.get('disabled'))



  _getImageWidget: (widget) ->
    if widget instanceof App.Models.SpriteOrientation
      widget.spriteWidget()
    else
      widget


  animationDurationChanged: ->
    @$('[name=animation-duration]').val @model.get('animation_duration')


  invalidAnimationDurationEntered: (duration) ->
    alert "Please enter a positive, one-decimal number for animation duration (e.g. 0, 3, 4.5). #{@$('[name=animation-duration]').val()} is not allowed"
