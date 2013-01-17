#= require ./widget

# RFCTR move these to class constants
# COLOR_OUTER_STROKE = 'rgba(15, 79, 168, 0.8)'
# COLOR_OUTER_FILL =   'rgba(174, 204, 246, 0.66)'
# COLOR_INNER_STROKE = 'rgba(15, 79, 168, 1)'
# COLOR_INNER_FILL =   'rgba(255, 255, 255, 1)'

# CURSOR_DEFAULT = 'default'
# CURSOR_MOVE =    'move'
# CURSOR_RESIZE =  'se-resize'

# DEFAULT_OPACITY =   150
# HIGHLIGHT_OPACITY = 230
# MOUSEOVER_OPACITY = 255


# LINE_WIDTH_OUTER = 2
# LINE_WIDTH_INNER = 2

# CSS_SCALE_FACTOR = 0.59

#
# Represent a Hotspot widget, as a circle that can be moved. It can be resized using
# a dedicated UI control (a small circle).
#
# It reacts to mouseOver and mouseOut.
#
# It belongs to a Scene (and has the same properties across all the keyframes
# of that scene. If you move it or scale it in one keyframe, it will have the
# new position / scale in all the keyframes)
#
# TODO RFCTR Rename to Hotspot. Extract a Backbone model.
class App.Builder.Widgets.TouchWidget extends App.Builder.Widgets.Widget

  # constructor: (options={}) ->
    # super

    # @scene(options.scene)
    # @type      = 'TouchWidget'

    # @action_id ?= options.action_id
    # @video_id  ?= options.video_id
    # @sound_id  ?= options.sound_id
    # @setZOrder(1000) #HACK TODO: Get rid of hardcode

    # @setOpacity(DEFAULT_OPACITY)
    # @on('mousedown', @onMouseDown, this)
    # @on('mouseup',   @onMouseUp,   this)
    # @on('mousemove', @onMouseMove, this)
    # @on('change',    @update,      this)
    # @on('mouseover', @onMouseOver, this)
    # @on('mouseout',  @onMouseOut,  this)


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
      # @setRadius(@_distanceFromCenter(point) + @_resizeOffset)


  # onMouseUp: (e) ->
    # @onMouseOut()
    # @_endResize(e)


  # doubleClick: ->
    # App.Builder.Widgets.WidgetDispatcher.trigger('widget:touch:edit', this)


  # getRadius: ->
    # @_radius


  # setRadius: (r) ->
    # r = 16 if r < 16
    # @_radius = r
    # @setContentSize(new cc.Size(@_radius * 2, @_radius * 2))

    # this


  # setControlRadius: (r) ->
    # @_controlRadius = r

    # this


  # getControlRadius: ->
    # @_controlRadius


  # getControlCenter: ->
    # radius = @getRadius()
    # controlRadius = @getControlRadius()

    # return new cc.Point(
      # (radius - controlRadius) * Math.sin(cc.DEGREES_TO_RADIANS(135))
      # (radius - controlRadius) * -Math.cos(cc.DEGREES_TO_RADIANS(135))
    # )

  # draw: (ctx) ->
    # r = @getRadius()
    # cr = @getControlRadius()

    # # FIXME We should monkey patch cocos2d-html5 to support opacity
    # ctx.save()
    # ctx.globalAlpha = @getOpacity() / 255.0

    # # Main Circle
    # ctx.beginPath()
    # ctx.arc(0, 0, r, 0 , Math.PI * 2, false)
    # ctx.strokeStyle = COLOR_OUTER_STROKE
    # ctx.lineWidth = LINE_WIDTH_OUTER
    # ctx.stroke()
    # ctx.beginPath()
    # ctx.arc(0, 0, r - (LINE_WIDTH_OUTER / 2), 0 , Math.PI * 2, false)
    # ctx.fillStyle = COLOR_OUTER_FILL
    # ctx.fill()

    # # Resizer
    # center = @getControlCenter()
    # ctx.beginPath()
    # ctx.arc(center.x, center.y, cr, 0, Math.PI * 2, false)
    # ctx.strokeStyle = COLOR_INNER_STROKE
    # ctx.lineWidth = LINE_WIDTH_INNER
    # ctx.stroke()
    # ctx.beginPath()
    # ctx.arc(center.x, center.y, cr - (LINE_WIDTH_INNER / 2), 0, Math.PI * 2, false)
    # ctx.fillStyle = COLOR_INNER_FILL
    # ctx.fill()

    # ctx.restore()


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


