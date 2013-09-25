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


  constructor: (options) ->
    super

    @_border = false

    @sprite = new App.Builder.Widgets.Lib.Sprite(options)

    @loadImage()


  loadImage: ->
    cc.TextureCache.sharedTextureCache().addImageAsync @model.url(), @, ( ->
      window.setTimeout @_imageLoadedInSprite, 0
    )


  _imageLoadedInSprite: =>
      @sprite.initWithFile @model.url()

      if @model instanceof App.Models.SpriteWidget
        currentOrientation = @model.getOrientationFor(App.currentSelection.get('keyframe'))
        # if the user switched to another scene while the image was loading, the orientation
        # will not exist
        if currentOrientation?
          @applyOrientation(currentOrientation)
      else
        @applyOrientation(@model)

      @addChild @sprite

      window.setTimeout @checkLoadedStatus, 0


  checkLoadedStatus: =>
    if @isLoaded()
      @setContentSize @sprite.getContentSize()
      @setOpacity()
    else
      window.setTimeout @checkLoadedStatus, 200


  # NOTE:
  #    There addImageSync() from Cocos2d, used in the constructor,
  #    may be worth using instead of this?
  #
  isLoaded: ->
    size = @sprite.getContentSize()
    @sprite._texture.complete && (size.width + size.height > 0)


  applyOrientation: (orientation) ->
    if @currentOrientation != orientation
      @currentOrientation?.off('change:scale', @_changeScale, @)
      @currentOrientation?.off('change:position', @_changePosition, @)
      @currentOrientation = orientation
      @currentOrientation.on('change:scale', @_changeScale, @)
      @currentOrientation.on('change:position', @_changePosition, @)

    position = orientation.get('position')
    @setPosition(new cc.Point(position.x, position.y))

    @_changeScale null, orientation.get('scale')


  _changeScale: (__, scale) ->
    @setScaleX scale.horizontal / 100
    @setScaleY scale.vertical   / 100


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

    scaleX = @sprite.getScaleX()
    scaleY = @sprite.getScaleY()
    x = (@sprite.getContentSize().width  * scaleX) * (@sprite.getAnchorPoint().x * -1)
    y = (@sprite.getContentSize().height * scaleY) * (@sprite.getAnchorPoint().y * -1)
    width =  @sprite.getContentSize().width  * scaleX
    height = @sprite.getContentSize().height * scaleY
    ctx.rect(x, y, width, height)

    ctx.strokeStyle = COLOR_OUTER_STROKE
    ctx.lineWidth = Math.round(LINE_WIDTH_OUTER * (scaleX + scaleY) / 2)
    ctx.stroke()

    ctx.beginPath()
    ctx.fillStyle = COLOR_OUTER_FILL
    ctx.fill()

    ctx.restore()

