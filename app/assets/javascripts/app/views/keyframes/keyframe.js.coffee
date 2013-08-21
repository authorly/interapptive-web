class App.Views.Keyframe extends Backbone.View
  template: JST["app/templates/keyframes/keyframe"]
  tagName: 'li'

  events:
    "change [name='animation-duration']": "updateAnimationDuration"

  initialize: ->
    @model.widgets.on        'add remove change:position change:scale change:radius',  @widgetsChanged, @
    @model.scene.widgets.on  '           change:position change:scale change:z_order change:disabled', @widgetsChanged, @


  remove: ->
    @model.widgets.off       'add remove change:position change:chale change:radius',  @widgetsChanged, @
    @model.scene.widgets.off '           change:position change:scale change:z_order change:disabled', @widgetsChanged, @


  render: ->
    @$el.html(@template(keyframe: @model)).attr('data-id', @model.id)
    if @model.isAnimation()
      @$el.attr('data-is_animation', '1').addClass('animation')
    if @model.preview.isNew()
      @renderPreview()

    @


  updateAnimationDuration: (event) ->
    @model.set animation_duration: Number($(event.currentTarget).val())


  widgetsChanged: (model) ->
    if model instanceof App.Models.HotspotWidget or
       model instanceof App.Models.SpriteOrientation or
       model instanceof App.Models.ImageWidget
      @renderPreview()


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
