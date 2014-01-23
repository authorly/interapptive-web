##
# A `Widget` is an entity that has a graphical representation and that
# responds to user interactions.
#
# Widget attributes are managed via the @model property (Backbone model)
#
# Graphical properties:
# _opacity
# _highlighted
# _mouse_over
#
# When inheriting from this class (i.e., SpriteWidget):
#   - Must set @setPosition, @setScale, etc. on the class and cocos2d object
#     created in the class.
#
#     *This is required in class inheriting from
#      Widget when setting visual attributes of
#      a cocos2d object (scale, position, etc.)
#
#          SpriteWidget i.e.,
#          @sprite = cc.sprite.create(...)
#          @sprite.setScale(SCALE)
#          @setScale(SCALE)
#
class App.Builder.Widgets.Widget extends cc.Node

  constructor: (options) ->
    super

    @model = options.model
    _.extend(this, Backbone.Events)
    @model.on 'change:position', @updatePosition, @
    @model.on 'change:z_order', @updateZOrder, @

    @_mouse_over = false

    @updatePosition()
    @updateZOrder()
    @setOpacity(255)


  setOpacity: (opacity) ->
    @_opacity = opacity


  getOpacity: ->
    @_opacity


  updatePosition: ->
    position = @model.get('position')
    if position?
      @setPosition new cc.Point(position.x, position.y)


  updateZOrder: ->
    @_zOrder = @model.get('z_order')


  mouseOver: ->
    @_mouse_over = true


  mouseOut: ->
    @_mouse_over = false


  # options: { touch, canvasPoint }
  mouseDown: (options) ->


  mouseUp: ->
    widget = @model
    if widget instanceof App.Models.SpriteWidget
      widget = @currentOrientation

    position = @getPosition()
    widget.set position: {x: position.x, y: position.y}


  mouseMove: ->


  select: ->


  dragged: (previousPoint, newPoint) ->
    delta = cc.pSub(newPoint, previousPoint)
    newPosition = cc.pAdd(delta, @getPosition())
    newPosition =
      x: Math.round(newPosition.x)
      y: Math.round(newPosition.y)
    model =
      if @model instanceof App.Models.SpriteWidget
        @currentOrientation
      else
        @model
    model.trigger 'move', newPosition

    @setPosition newPosition


  rect: ->
    p = @getPosition()
    s = @getContentSize()
    a = @getAnchorPoint()
    scale = @getScale()

    cc.rect(
      p.x - s.width  * scale * a.x
      p.y - s.height * scale * a.y
      s.width  * scale
      s.height * scale
    )


  pointToLocal: (point) =>
    return unless @parent?

    # Fix bug in cocos2d-html5; It doesn't convert to local space correctly
    r = @rect()
    root = @parent.getPosition()
    anchor = @parent.getAnchorPoint()
    new cc.Point(-root.x - r.x + point.x + anchor.x * r.width,
                 -root.y - r.y + point.y + anchor.y * r.height)


  isPointInside: (point) ->
    cc.rectContainsPoint @rect(), point


  isSpriteWidget: ->
    @model instanceof App.Models.SpriteWidget


  isButtonWidget: ->
    @model instanceof App.Models.ButtonWidget


  isImageWidget: ->
    @model instanceof App.Models.ImageWidget


  isTextWidget: ->
    @model instanceof App.Models.TextWidget


  isHotspotWidget: ->
    @model instanceof App.Models.HotspotWidget
