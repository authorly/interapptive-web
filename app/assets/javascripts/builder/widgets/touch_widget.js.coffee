#= require ./widget

COLOR_OUTER_STROKE = 'rgba(15, 79, 168, 0.8)'
COLOR_OUTER_FILL = 'rgba(174, 204, 246, 0.66)'
LINE_WIDTH_OUTER = 2
COLOR_INNER_STROKE = 'rgba(15, 79, 168, 1)'
COLOR_INNER_FILL = 'rgba(255, 255, 255, 1)'
LINE_WIDTH_INNER = 2
DEFAULT_OPACITY = 150

class App.Builder.Widgets.TouchWidget extends App.Builder.Widgets.Widget

  @newFromHash: (hash) ->
    widget = super
    widget.setRadius(hash.radius) if hash.radius

    #HACK TODO: Remove hardcore
    widget.setZOrder(1000) #HACK TODO: Get rid of hardcode
    return widget

  constructor: (options={}) ->
    super

    @setRadius(options.radius || 32)
    @setControlRadius(options.controlRadius || 8)

    @setOpacity(DEFAULT_OPACITY)
    @on('mouseover', @onMouseOver, this)
    @on('mouseout',  @onMouseOut,  this)
    @on('mousedown', @onMouseDown, this)
    @on('mouseup',   @onMouseUp,   this)
    @on('mousemove', @onMouseMove, this)

  # TODO: What do these two even do? Why do we need bind here?
  onMouseOver: (e) ->
    @setOpacity.bind(this, 255)
    point = e.canvasPoint

  onMouseOut: (e) ->
    @setOpacity.bind(this, 200)

    unless @resizing
      document.body.style.cursor = 'default'

  onMouseDown: (e) ->
    point = e.canvasPoint
    inControl = @isPointInsideControl(point)

    @draggable = not inControl

    @startResize(e) if inControl

  onMouseMove: (e) ->
    point = e.canvasPoint

    inControl = @resizing or @isPointInsideControl(point)
    document.body.style.cursor = if inControl then 'se-resize' else 'move'

    if @resizing
      @setRadius(@distanceFromCenter(point) + @_resizeOffset)

  onMouseUp: (e) ->
    @endResize(e)

  doubleClick: ->
    App.Builder.Widgets.WidgetDispatcher.trigger('widget:touch:edit', this)

  startResize: (e) ->
    @resizing = true
    @_resizeOffset = @getRadius() - @distanceFromCenter(e.canvasPoint)
    document.body.style.cursor = 'se-resize'

  endResize: (e) ->
    @resizing = false

    point = e.canvasPoint
    if @isPointInside(point)
      document.body.style.cursor = 'move'
    else if @isPointInsideControl(point)
      document.body.style.cursor = 'se-resize'
    else
      document.body.style.cursor = 'default'


  isPointInsideControl: (point) ->
    local = @pointToLocal(point)

    # Adjust origin to centre of circle
    local.x -= @getRadius()
    local.y -= @getRadius()

    # Centre of control circle relative to parent circle's centre
    center = @getControlCenter()

    # Distance to centre of control
    xLen = center.x - local.x
    yLen = center.y + local.y # Y axis is inverted
    dist = Math.sqrt((xLen * xLen) + (yLen * yLen))

    return (dist < @getControlRadius())

  setRadius: (r) ->
    r = 16 if r < 16
    @_radius = r
    @setContentSize(new cc.Size(@_radius * 2, @_radius * 2))

    this

  setControlRadius: (r) ->
    @_controlRadius = r

    this

  getRadius: ->
    @_radius

  getControlRadius: ->
    @_controlRadius

  getControlCenter: ->
    radius = @getRadius()
    controlRadius = @getControlRadius()

    return new cc.Point(
      (radius - controlRadius) * Math.sin(cc.DEGREES_TO_RADIANS(135))
      (radius - controlRadius) * -Math.cos(cc.DEGREES_TO_RADIANS(135))
    )

  draw: (ctx) ->
    r = @getRadius()
    cr = @getControlRadius()

    # FIXME We should monkey patch cocos2d-html5 to support opacity
    ctx.save()
    ctx.globalAlpha = @getOpacity() / 255.0

    # Main Circle
    ctx.beginPath()
    ctx.arc(0, 0, r, 0 , Math.PI * 2, false)
    ctx.strokeStyle = COLOR_OUTER_STROKE
    ctx.lineWidth = LINE_WIDTH_OUTER
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(0, 0, r - (LINE_WIDTH_OUTER / 2), 0 , Math.PI * 2, false)
    ctx.fillStyle = COLOR_OUTER_FILL
    ctx.fill()

    # Resizer
    center = @getControlCenter()
    ctx.beginPath()
    ctx.arc(center.x, center.y, cr, 0, Math.PI * 2, false)
    ctx.strokeStyle = COLOR_INNER_STROKE
    ctx.lineWidth = LINE_WIDTH_INNER
    ctx.stroke()
    ctx.beginPath()
    ctx.arc(center.x, center.y, cr - (LINE_WIDTH_INNER / 2), 0, Math.PI * 2, false)
    ctx.fillStyle = COLOR_INNER_FILL
    ctx.fill()

    ctx.restore()

  toHash: ->
    hash = super
    hash.radius = @_radius
    hash.controlRadius = @_controlRadius

    hash

  distanceFromCenter: (point) ->
    radius = @getRadius()
    local = @pointToLocal(point)

    xLen = local.x - radius
    yLen = local.y - radius
    return Math.sqrt((xLen * xLen) + (yLen * yLen))

  # Overridden to make hit area circular
  isPointInside: (point) ->
    inRect = super
    return false unless inRect
    return (@distanceFromCenter(point) < @getRadius())

  highlight: ->
    super
    @setOpacity(230)

  unHighlight: ->
    super
    @setOpacity(DEFAULT_OPACITY)
