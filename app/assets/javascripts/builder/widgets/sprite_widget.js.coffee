#= require ./widget

##
# Show a SpriteWidget as a cc.Sprite.
#
# Graphical properties:
# _border
#
class App.Builder.Widgets.SpriteWidget extends App.Builder.Widgets.Widget
  COLOR_OUTER_STROKE = 'rgba(15, 79, 168, 0.8)'
  COLOR_OUTER_FILL = 'rgba(174, 204, 246, 0.66)'
  COLOR_INNER_FILL = 'rgba(255, 255, 255, 1)'
  LINE_WIDTH_OUTER = 2
  IMAGE_RETRY_LOADING_AFTER = 5 # seconds

  constructor: (options) ->
    super

    @_border = false
    @options = options

    @sprite = new App.Builder.Widgets.Lib.Sprite(@options)
    @model.on 'change:image_id', @loadImage, @
    @loadImage()


  loadImage: =>
    cache = cc.TextureCache.getInstance()
    texture = cache.addImageAsync @_url(), @, @_imageLoaded

    # cocos2d v2.2.2 doesn't expose an error handler, so we're going
    # into its interanals to hook onto the `img`'s error handler
    @image = texture._htmlElementObj
    @image.addEventListener 'error', @_imageErrored


  onExit: ->
    @image.removeEventListener 'error', @_imageErrored
    super


  _imageLoaded: =>
    @sprite.initWithFile @_url()
    @sprite.setAnchorPoint new cc.Point(0, 0)

    if @model instanceof App.Models.SpriteWidget
      currentOrientation = @model.getOrientationFor(App.currentSelection.get('keyframe'))
      # if the user switched to another scene while the image was loading, the orientation
      # will not exist
      if currentOrientation?
        @applyOrientation(currentOrientation)
    else
      @applyOrientation(@model)

    @addChild @sprite
    @setContentSize @sprite.getContentSize()
    @setAnchorPoint new cc.Point(0.5, 0.5)
    @setOpacity()


  # Prevent getting images from cache, see #1235#issuecomment-35939013
  # @2014-02-24 @dira
  _url: =>
    @model.url() + '?prevent-cache-lookup=1'


  _imageErrored: =>
    if @isRunning()
      @_showImageLoadingError() unless @imageLoadingRetried
      @imageLoadingRetried = true

      window.setTimeout @loadImage, IMAGE_RETRY_LOADING_AFTER * 1000


  _showImageLoadingError: ->
    message = "Could not load #{@model.image().get('name')}, but we keep trying"
    App.vent.trigger 'show:message', 'warning', message


  getModelForPositioning: ->
    if @model instanceof App.Models.SpriteWidget
      @currentOrientation
    else
      @model


  applyOrientation: (orientation) ->
    if @currentOrientation != orientation
      @stopListening @currentOrientation

      @currentOrientation = orientation

      @listenTo @currentOrientation, 'change:scale',    @_changeScale
      @listenTo @currentOrientation, 'change:position', @_changePosition

    position = orientation.get('position')
    @setPosition(new cc.Point(position.x, position.y))

    scale = parseFloat(orientation.get('scale'))
    @_changeScale(null, scale)


  _changeScale: (__, scale) ->
    @setScale scale
    @_size = @getContentSize()


  _changePosition: (__, position) ->
    @setPosition position


  select: ->
    @selected = true
    @showBorder()


  deselect: ->
    @selected = false
    @hideBorder()


  mouseOver: ->
    @parent.setCursor('move')
    @showBorder()


  mouseOut: ->
    @parent.setCursor('default')
    @hideBorder() unless @selected


  showBorder: =>
    @_border = true


  hideBorder: =>
    @_border = false


  hasBorder: =>
    @_border


  setOpacity: (opacity=@_lastOpacity) ->
    super
    @sprite?.setOpacity(opacity)
    @_lastOpacity = opacity


  draw: (ctx) ->
    return unless @hasBorder()

    # FIXME We should monkey patch cocos2d-html5 to support opacity
    # checkout https://github.com/cocos2d/cocos2d-html5/blob/Cocos2d-html5-v0.5.0-alpha2/tests/Classes/tests/SpriteTest/SpriteTest.js#L745
    ctx.save()
    ctx.globalAlpha = @getOpacity() / 255.0

    ctx.beginPath()

    ctx.rect(0, -@_size.height, @_size.width, @_size.height)

    ctx.strokeStyle = COLOR_OUTER_STROKE
    ctx.lineWidth = Math.round(LINE_WIDTH_OUTER / @getScale())
    ctx.stroke()

    ctx.beginPath()
    ctx.fillStyle = COLOR_OUTER_FILL
    ctx.fill()

    ctx.restore()

