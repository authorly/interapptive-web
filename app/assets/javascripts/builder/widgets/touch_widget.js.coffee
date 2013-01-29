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
  OUTER_STROKE_COLOR: 'rgba(15, 79, 168, 0.8)'
  OUTER_STROKE_WIDTH: 2
  OUTER_STROKE_FILL:   'rgba(174, 204, 246, 0.66)'
  INNER_STROKE_COLOR: 'rgba(15, 79, 168, 1)'
  INNER_STROKE_WIDTH: 2
  INNER_STROKE_FILL:   'rgba(255, 255, 255, 1)'

  # CURSOR_DEFAULT: 'default'
  # CURSOR_MOVE:    'move'
  # CURSOR_RESIZE:  'se-resize'

  DEFAULT_OPACITY:   150
  HIGHLIGHT_OPACITY: 230
  MOUSEOVER_OPACITY: 255


  # CSS_SCALE_FACTOR: 0.59


  constructor: (options={}) ->
    super
    @setOpacity @DEFAULT_OPACITY

    @model.on 'change:radius', @updateContentSize, @
    @model.on 'change:position', @updatePosition, @

    # @scene(options.scene)
    # @type      = 'TouchWidget'

    # @action_id ?= options.action_id
    # @video_id  ?= options.video_id
    # @sound_id  ?= options.sound_id
    # @setZOrder(1000) #HACK TODO: Get rid of hardcode

    # @on('mousedown', @onMouseDown, this)
    # @on('mouseup',   @onMouseUp,   this)
    # @on('mousemove', @onMouseMove, this)
    # @on('change',    @update,      this)
    # @on('mouseover', @onMouseOver, this)
    # @on('mouseout',  @onMouseOut,  this)


  draw: (ctx) ->
    r = @model.get('radius')
    cr = @model.get('controlRadius')

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
    diameter = @model.get(radius) * 2
    @setContentSize(new cc.Size(diameter, diameter))


  getControlCenter: ->
    radius = @model.get('radius')
    controlRadius = @model.get('controlRadius')

    return new cc.Point(
      (radius - controlRadius) *  Math.sin(cc.DEGREES_TO_RADIANS(135))
      (radius - controlRadius) * -Math.cos(cc.DEGREES_TO_RADIANS(135))
    )


  # Reload attributes from a set of keypairs
  # Useful for form submission
  # loadFromHash: (hash, options) =>
    # _.extend(@, hash)
    # options?.success?(@)

  # scene: ->
    # if arguments.length > 0
      # @_scene = arguments[0]
    # else
      # @_scene


  # onMouseOver: (e) =>
    # @setOpacity(MOUSEOVER_OPACITY)


  # onMouseOut: (e) =>
    # @setOpacity(DEFAULT_OPACITY)
    # unless @resizing
      # document.body.style.cursor = CURSOR_DEFAULT


  # onMouseDown: (e) ->
    # point = e.canvasPoint
    # inControl = @_isPointInsideControl(point)

    # @draggable = not inControl

    # @_startResize(e) if inControl


  # onMouseMove: (e) ->
    # point = e.canvasPoint

    # inControl = @resizing or @_isPointInsideControl(point)
    # document.body.style.cursor = if inControl then CURSOR_RESIZE else CURSOR_MOVE

    # if @resizing
      # @model.set radius: @_distanceFromCenter(point) + @_resizeOffset


  # onMouseUp: (e) ->
    # @onMouseOut()
    # @_endResize(e)


  # doubleClick: ->
    # App.Builder.Widgets.WidgetDispatcher.trigger('widget:touch:edit', this)




  # setControlRadius: (r) ->
    # @_controlRadius = r

    # this


  # getControlRadius: ->
    # @_controlRadius





  # # Overridden to make hit area circular
  # isPointInside: (point) ->
    # inRect = super
    # return false unless inRect
    # return (@_distanceFromCenter(point) < @getRadius() * CSS_SCALE_FACTOR)


  # highlight: ->
    # super
    # @setOpacity(HIGHLIGHT_OPACITY)


  # unHighlight: ->
    # super
    # @setOpacity(DEFAULT_OPACITY)


  # toHash: ->
    # hash               = super
    # hash.type          = @type
    # hash.id            = @id
    # hash.radius        = parseInt(@_radius)
    # hash.controlRadius = @_controlRadius
    # hash.action_id     = @action_id
    # hash.video_id      = @video_id
    # hash.sound_id      = @sound_id

    # hash


  # update: ->
    # widgets = App.currentScene().get('widgets') || []
    # _.each widgets, (widget) =>
      # if @id is widget.id
        # widget.position = @_position
        # widget.radius   = parseInt(@_radius)

    # App.currentScene().set('widgets', widgets)
    # App.currentScene().save {},
      # success: =>
        # # console.log "Update JSON for touch widget"
        # # App.storybookJSON.updateSpriteOrientationWidget(this)
      # error: =>
        # console.log("TouchWidget did not update")


  # _distanceFromCenter: (point) ->
    # radius = @getRadius()
    # local = @pointToLocal(point)

    # xLen = local.x - radius
    # yLen = local.y - radius
    # return Math.sqrt((xLen * xLen) + (yLen * yLen)) * CSS_SCALE_FACTOR



  # _startResize: (e) ->
    # @resizing = true
    # @_resizeOffset = @getRadius() - @_distanceFromCenter(e.canvasPoint)
    # document.body.style.cursor = 'se-resize'


  # _endResize: (e) ->
    # @resizing = false

    # point = e.canvasPoint
    # if @isPointInside(point)
      # document.body.style.cursor = 'move'
    # else if @_isPointInsideControl(point)
      # document.body.style.cursor = 'se-resize'
    # else
      # document.body.style.cursor = 'default'

    # App.currentScene().widgetsChanged()


  # _isPointInsideControl: (point) ->
    # local = @pointToLocal(point)

    # # Adjust origin to centre of circle
    # local.x -= @getRadius()
    # local.y -= @getRadius()

    # # Centre of control circle relative to parent circle's centre
    # center = @getControlCenter()

    # # Distance to centre of control
    # xLen = center.x - local.x
    # yLen = center.y + local.y # Y axis is inverted
    # dist = Math.sqrt((xLen * xLen) + (yLen * yLen))

    # return (dist < @getControlRadius())


