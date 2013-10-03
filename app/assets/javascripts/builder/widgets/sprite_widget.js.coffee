#= require ./widget

##
# Show a SpriteWidget as a cc.Sprite.
#
# Graphical properties:
# _border
#
class App.Builder.Widgets.SpriteWidget extends App.Builder.Widgets.Widget
  BORDER_WIDTH = 4
  BORDER_COLOR = 'rgba(15, 79, 168, 0.8)'

  CONTROL_SIZE = 12
  CONTROL_FILL_COLOR = 'rgba(255, 255, 255, 1)'

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

      # negative z-order, so the contents of this node (the highlight border)
      # are drawn on top of the sprite
      @addChild @sprite, -1

      window.setTimeout @checkLoadedStatus, 0


  checkLoadedStatus: =>
    if @isLoaded()
      @applyOrientation(@currentOrientation)
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
    @sprite.setScaleX scale.horizontal * 0.01
    @sprite.setScaleY scale.vertical   * 0.01

    size = @sprite.getContentSize()
    size.width  = Math.round(size.width  * scale.horizontal * 0.01)
    size.height = Math.round(size.height * scale.vertical   * 0.01)
    @setContentSize size


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

    scaleX = @sprite.getScaleX()
    scaleY = @sprite.getScaleY()
    size = @sprite.getContentSize()
    anchor = @sprite.getAnchorPoint()

    width =  size.width  * scaleX
    height = size.height * scaleY
    x = width  * (anchor.x * -1)
    y = height * (anchor.y * -1)

    # border
    ctx.beginPath()
    ctx.strokeStyle = BORDER_COLOR
    ctx.lineWidth = BORDER_WIDTH
    ctx.rect(x, y, width, height)
    ctx.stroke()

    if @selected
      # corners
      ctx.beginPath()
      ctx.fillStyle = CONTROL_FILL_COLOR
      cornerSize = CONTROL_SIZE
      for [dx, dy] in [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
        ctx.rect(x + (dx+1) * width * 0.5 - cornerSize * 0.5, y + (dy+1) * height * 0.5 - cornerSize * 0.5, cornerSize, cornerSize)
      ctx.stroke()
      ctx.fill()

    ctx.restore()

