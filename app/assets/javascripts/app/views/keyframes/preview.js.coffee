class App.Views.Preview extends Backbone.View

  initialize: ->
    @imageCache = App.Lib.ImageCache.instance()
    @listenTo @model, 'invalid', ->
      # let all the changes propagate (e.g. delete sprite -> delete orientations)
      window.setTimeout @_render, 0


  render: ->
    if @model.isNew() || @model.isInvalid()
      @_render()
    else
      @$el.html("<img src='#{@model.src()}'/>")
      @$('img').on 'dragstart', ->
        # do not allow dragging images around
        false
    @


  _render: =>
    images = _.map @model.spritesToRender(), (widget) =>
      @imageCache.get @_getImageUrl(widget)
    # make sure that, if there is only one image, we pass an array with at
    # 2 elements, to make jquery invoke the callback with an array of results
    images.push [null, null] if images.length < 2

    $.when.apply($, images).then @_renderCallback


  _renderCallback: (images...) =>
    @_ensureCanvasCreated()

    @previewCtx.clearRect 0, 0, 150, 112
    @_renderImages(images)
    @_renderHotspots()

    @_exportPreview()


  _ensureCanvasCreated: ->
    return if @$('canvas').length > 0

    @$el.html "<canvas width='#{@options.width}' height='#{@options.height}'/>"
    @previewCanvas = @$('canvas')[0]
    @previewHeight = @previewCanvas.height
    @previewCtx = @previewCanvas.getContext('2d')
    @previewCtx.fillStyle = 'rgba(174, 204, 246, 0.66)'
    @previewScale = @previewCanvas.width * 1.0 / App.Config.dimensions.width


  _renderHotspots: ->
    for widget in @model.keyframe.hotspotWidgets()
      position = widget.get('position')

      @previewCtx.beginPath()
      @previewCtx.arc position.x * @previewScale,
                      @previewHeight - position.y * @previewScale,
                      widget.get('radius') * @previewScale,
                      0, 360
      @previewCtx.fill()


  _renderImages: (imageLoadResults) ->
    imagesByUrl = _.object(imageLoadResults)
    widgets = @model.spritesToRender().sort (w1, w2) =>
      @_getImageWidget(w1).get('z_order') - @_getImageWidget(w2).get('z_order')

    _.each widgets, (widget) =>
      position = widget.get('position')
      scale = widget.get('scale')
      img = imagesByUrl[@_getImageUrl(widget)]

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
    return if @options.skipSave

    image = Canvas2Image.saveAsPNG @previewCanvas, true
    @model.setDataUrl image.src


  _getImageUrl: (widget) ->
    @_getImageWidget(widget).image().get('url')


  _getImageWidget: (widget) ->
    if widget instanceof App.Models.SpriteOrientation
      widget.spriteWidget()
    else
      widget
