#= require ./widget

#
# Show a Hotspot widget, as a cc circle. It can be moved. It can be resized using
# a dedicated UI control (a small circle).
#
# It reacts to mouseOver and mouseOut.
#
# It belongs to a Scene (and has the same properties across all the keyframes
# of that scene. If you move it or scale it in one keyframe, it will have the
# new position / scale in all the keyframes)
#
class App.Builder.Widgets.HotspotWidget extends App.Builder.Widgets.Widget
  DEFAULT_OPACITY:   150
  HIGHLIGHT_OPACITY: 230
  MOUSEOVER_OPACITY: 255

  CURSOR_DEFAULT: 'default'
  CURSOR_MOVE:    'move'
  CURSOR_RESIZE:  'se-resize'

  OUTER_STROKE_COLOR: 'rgba(15, 79, 168, 0.8)'
  OUTER_STROKE_WIDTH: 2
  OUTER_STROKE_FILL:   'rgba(174, 204, 246, 0.66)'
  INNER_STROKE_COLOR: 'rgba(15, 79, 168, 1)'
  INNER_STROKE_WIDTH: 2
  INNER_STROKE_FILL:   'rgba(255, 255, 255, 1)'


  constructor: (options) ->
    super
    @setOpacity @DEFAULT_OPACITY
    @updateContentSize()

    @model.on 'change:radius', @updateContentSize, @
    @model.on 'change:position', @updatePosition, @


  draw: (ctx) ->
    r = @model.get('radius')
    cr = @model.get('control_radius')

    # FIXME We should monkey patch cocos2d-html5 to support opacity
    ctx.save()
    ctx.globalAlpha = @getOpacity() / 255.0

    # Main Circle
    ctx.beginPath()
    ctx.arc(0, 0, r, 0 , Math.PI * 2, false)
    ctx.strokeStyle = @OUTER_STROKE_COLOR
    ctx.lineWidth = @OUTER_STROKE_WIDTH
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(0, 0, r - (@OUTER_STROKE_WIDTH / 2), 0 , Math.PI * 2, false)
    ctx.fillStyle = @OUTER_STROKE_FILL
    ctx.fill()

    # Resizer
    center = @getControlCenter()
    ctx.beginPath()
    ctx.arc(center.x, center.y, cr, 0, Math.PI * 2, false)
    ctx.strokeStyle = @INNER_STROKE_COLOR
    ctx.lineWidth = @INNER_STROKE_WIDTH
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(center.x, center.y, cr - (@INNER_STROKE_WIDTH / 2), 0, Math.PI * 2, false)
    ctx.fillStyle = @INNER_STROKE_FILL
    ctx.fill()

    ctx.restore()


  updateContentSize: ->
    diameter = @model.get('radius') * 2
    @setContentSize(new cc.Size(diameter, diameter))


  getControlCenter: ->
    radius = @model.get('radius')
    controlRadius = @model.get('control_radius')

    return new cc.Point(
      (radius - controlRadius) *  Math.sin(cc.DEGREES_TO_RADIANS(135))
      (radius - controlRadius) * -Math.cos(cc.DEGREES_TO_RADIANS(135))
    )


  mouseOver: ->
    super
    @setOpacity(@MOUSEOVER_OPACITY)


  mouseOut:  ->
    super
    unless @resizing
      @setOpacity(@DEFAULT_OPACITY)
      @setCursor @CURSOR_DEFAULT


  mouseDown: (options) ->
    point = options.canvasPoint
    inControl = @_isPointInsideControl(point)

    @_startResize(options) if inControl


  mouseUp: (options) ->
    if @resizing
      @_endResize(options)
    else
      super


  doubleClick: ->
    # TODO deal with this - but not in the old WidgetDispatcher
    # App.vent.trigger('widget:touch:edit', this)


  draggedTo: ->
    super unless @resizing


  mouseMove: (options) ->
    point = options.canvasPoint

    inControl = @resizing or @_isPointInsideControl(point)
    @setCursor(if inControl then @CURSOR_RESIZE else @CURSOR_MOVE)

    @_updateRadius(point) if @resizing


  setCursor: (cursor) ->
    document.body.style.cursor = cursor


  # Overridden to make hit area circular
  isPointInside: (point) ->
    inRect = super
    return false unless inRect
    @_distanceFromCenter(point) < @model.get('radius')


  _distanceFromCenter: (point) ->
    radius = @model.get('radius')
    local = @pointToLocal(point)

    xLen = local.x - radius
    yLen = local.y - radius
    Math.sqrt((xLen * xLen) + (yLen * yLen))


  _isPointInsideControl: (point) ->
    local = @pointToLocal(point)

    # Adjust origin to centre of circle
    radius = @model.get('radius')
    local.x -= radius
    local.y -= radius

    # Centre of control circle relative to parent circle's centre
    center = @getControlCenter()

    # Distance to centre of control
    xLen = center.x - local.x
    yLen = center.y + local.y # Y axis is inverted
    dist = Math.sqrt((xLen * xLen) + (yLen * yLen))

    dist < @model.get('control_radius')


  _startResize: (e) ->
    @resizing = true
    @_resizeOffset = @model.get('radius') - @_distanceFromCenter(e.canvasPoint)
    @setCursor(@CURSOR_RESIZE)


  _endResize: (e) ->
    @resizing = false

    point = e.canvasPoint
    cursor = if @isPointInside(point)
      @CURSOR_MOVE
    else if @_isPointInsideControl(point)
      @CURSOR_RESIZE
    else
      @CURSOR_DEFAULT
    @setCursor(cursor)

    @_updateRadius(point)


  _updateRadius: (point) ->
    @_setRadius(@_distanceFromCenter(point) + @_resizeOffset)


  # TODO this enforcement of a min radius should be on the model
  # could not find an easy way to do this, though (without rewriting the first
  # part of `set`, which deals with the two forms of passing attributes
  # dira, 2013-01-29
  _setRadius: (radius) ->
    radius = @model.MIN_RADIUS if radius < @model.MIN_RADIUS
    @model.set radius: radius


  # highlight: ->
    # super
    # @setOpacity(HIGHLIGHT_OPACITY)


  # unHighlight: ->
    # super
    # @setOpacity(DEFAULT_OPACITY)
