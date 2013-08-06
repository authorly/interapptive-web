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
# radius - a local cache of the hotspot's radius; it is set to the model only
# when changes to it are finished (when drag is finished)
class App.Builder.Widgets.HotspotWidget extends App.Builder.Widgets.Widget
  DEFAULT_OPACITY:   150
  HIGHLIGHT_OPACITY: 230
  MOUSEOVER_OPACITY: 255

  OUTER_STROKE_COLOR: 'rgba(15, 79, 168, 0.8)'
  OUTER_STROKE_WIDTH: 2
  OUTER_STROKE_FILL:   'rgba(174, 204, 246, 0.66)'
  INNER_STROKE_COLOR: 'rgba(15, 79, 168, 1)'
  INNER_STROKE_WIDTH: 2
  INNER_STROKE_FILL:   'rgba(255, 255, 255, 1)'

  CONTROL_RADIUS: 28


  constructor: (options) ->
    super
    @setOpacity @DEFAULT_OPACITY

    @model.on 'change:radius', @updateRadius, @
    @updateRadius()


  updateRadius: ->
    @radius = @model.get 'radius'
    @updateContentSize()


  updateContentSize: ->
    diameter = @radius * 2
    @setContentSize(new cc.Size(diameter, diameter))


  draw: (ctx) ->
    r = @radius
    cr = @CONTROL_RADIUS

    # FIXME We should monkey patch cocos2d-html5 to support opacity
    ctx.save()
    opacity = if @selected then @MOUSEOVER_OPACITY else @getOpacity()
    ctx.globalAlpha = opacity / 255.0

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


  getControlCenter: ->
    return new cc.Point(
      (@radius - @CONTROL_RADIUS) *  Math.sin(cc.DEGREES_TO_RADIANS(135))
      (@radius - @CONTROL_RADIUS) * -Math.cos(cc.DEGREES_TO_RADIANS(135))
    )


  mouseOver: ->
    super
    @setOpacity(@MOUSEOVER_OPACITY)


  mouseOut:  ->
    super
    unless @resizing
      @setOpacity(@DEFAULT_OPACITY)
      @parent.setCursor 'default'



  mouseDown: (options) ->
    point = options.canvasPoint
    inControl = @_isPointInsideControl(point)

    @_startResize(options) if inControl


  mouseUp: (options) ->
    if @resizing
      @_endResize(options)
    else
      super


  select: ->
    @selected = true


  deselect: ->
    @selected = false


  draggedTo: ->
    super unless @resizing


  mouseMove: (options) ->
    point = options.canvasPoint

    inControl = @resizing or @_isPointInsideControl(point)
    @parent.setCursor(if inControl then 'resize' else 'move')

    @_resizeRadius(point) if @resizing


  # Overridden to make hit area circular
  isPointInside: (point) ->
    inRect = super
    return false unless inRect
    @_distanceFromCenter(point) < @radius


  _distanceFromCenter: (point) ->
    # Could not figure out why using @radius makes the UI go erratic. Nor why this
    # works.
    # I suppose that changing @radius at the same time as computing distances based on
    # it makes it err.
    # @dira 2013-02-04
    radius = @model.get('radius')
    local = @pointToLocal(point)

    xLen = local.x - radius
    yLen = local.y - radius
    Math.sqrt((xLen * xLen) + (yLen * yLen))


  _isPointInsideControl: (point) ->
    local = @pointToLocal(point)

    # Adjust origin to centre of circle
    local.x -= @radius
    local.y -= @radius

    # Centre of control circle relative to parent circle's centre
    center = @getControlCenter()

    # Distance to centre of control
    xLen = center.x - local.x
    yLen = center.y + local.y # Y axis is inverted
    dist = Math.sqrt((xLen * xLen) + (yLen * yLen))

    dist < @CONTROL_RADIUS


  _startResize: (e) ->
    @resizing = true
    @_resizeOffset = @radius - @_distanceFromCenter(e.canvasPoint)
    @parent.setCursor 'resize'


  _endResize: (e) ->
    @resizing = false

    point = e.canvasPoint
    cursor = if @isPointInside(point)
      'move'
    else if @_isPointInsideControl(point)
      'resize'
    else
      'default'
    @parent.setCursor(cursor)

    @_resizeRadius(point)
    @_setRadius @radius


  _resizeRadius: (point) ->
    @radius = @_distanceFromCenter(point) + @_resizeOffset


  # TODO this enforcement of a min radius should be on the model
  # could not find an easy way to do this, though (without rewriting the first
  # part of `set`, which deals with the two forms of passing attributes
  # dira, 2013-01-29
  _setRadius: (radius) ->
    radius = @model.MIN_RADIUS if radius < @model.MIN_RADIUS
    @model.set radius: radius
