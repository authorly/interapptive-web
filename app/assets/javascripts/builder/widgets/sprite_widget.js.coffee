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

  CURSORS =
    null: 'move'
    nw:   'nwse-resize'
    n:    'ns-resize'
    ne:   'nesw-resize'
    e:    'ew-resize'
    se:   'nwse-resize'
    s:    'ns-resize'
    sw:   'nesw-resize'
    w:    'ew-resize'

  constructor: (options) ->
    super

    @_border = false

    @sprite = new App.Builder.Widgets.Lib.Sprite(options)
    @model.on 'change:visualScale', @visualScaleChanged, @

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


  mouseMove: (options) ->
    point = @pointToLocal(options.canvasPoint)
    control = @controlFor(point)
    r = @rect()
    if @resizing
      width  = true
      height = true
      switch @resizeData.direction
        when 'n', 's'
          width = false
        when 'e', 'w'
          height = false
      if width
        dw = Math.abs(point.x - (r.origin.x + (r.size.width) * 0.5))
        sx = dw  * 2 / @resizeData.size.width * @resizeData.scale.horizontal
        @model.trigger 'change:visualScale', horizontal: Math.round(sx * 100)
      if height
        dh = Math.abs(point.y - (r.origin.y + (r.size.height) * 0.5))
        sy = dh * 2 / @resizeData.size.height * @resizeData.scale.vertical
        @model.trigger 'change:visualScale', vertical: Math.round(sy * 100)
    else
      @parent.setCursor CURSORS[control]


  visualScaleChanged: (scale) ->
    if scale.horizontal
      @sprite.setScaleX scale.horizontal * 0.01
    if scale.vertical
      @sprite.setScaleY scale.vertical * 0.01


  draggedTo: ->
    if @resizing
      return false
    else
      super


  mouseOver: ->
    @parent.setCursor('move')
    @showBorder()


  mouseOut: ->
    @parent.setCursor('default')
    @hideBorder() unless @selected


  mouseDown: (options) ->
    point = @pointToLocal(options.canvasPoint)
    if (control = @controlFor(point))?
      @resizing = true
      rect = @rect()
      @resizeData =
        direction: control
        scale:
          horizontal: @sprite.getScaleX()
          vertical:   @sprite.getScaleY()
        size: rect.size


  mouseUp: (options) ->
    if @resizing
      @resizing = false
      @currentOrientation.set
        scale:
          horizontal: Math.round(@sprite.getScaleX() * 100)
          vertical:   Math.round(@sprite.getScaleY() * 100)
    else
      super


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


  rect: ->
    r = super
    if @selected
      # Center anchor point => the origin does not need to be changed
      cc.RectMake(
        r.origin.x
        r.origin.y
        r.size.width  + CONTROL_SIZE
        r.size.height + CONTROL_SIZE
      )
    else
      r


  controlFor: (point) ->
    return null unless @selected

    r = @rect()
    cornerSize = CONTROL_SIZE

    hash =
      sw: [-1, -1]
      s:  [ 0, -1]
      se: [ 1, -1]
      e:  [ 1,  0]
      ne: [ 1,  1]
      n:  [ 0,  1]
      nw: [-1,  1]
      w:  [-1,  0]

    for dir, [dx, dy] of hash

      rect = cc.RectMake(
        r.origin.x + (dx+1) * 0.5 * (r.size.width  - cornerSize)
        r.origin.y + (dy+1) * 0.5 * (r.size.height - cornerSize)
        cornerSize
        cornerSize
      )
      return dir if cc.Rect.CCRectContainsPoint(rect, point)

    null


