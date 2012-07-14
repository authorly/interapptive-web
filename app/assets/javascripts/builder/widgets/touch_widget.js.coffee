#= require ./widget

class App.Builder.Widgets.TouchWidget extends App.Builder.Widgets.Widget

  @newFromHash: (hash) ->
    widget = super

    widget.setRadius(hash.radius) if hash.radius
    widget.setControlRadius(hash.controlRadius) if hash.controlRadius

    return widget

  constructor: (options={}) ->
    super

    @setRadius(options.radius || 32)
    @setControlRadius(options.controlRadius || 12)

    @setOpacity(150)
    @on('mouseover', @setOpacity.bind(this, 255))
    @on('mouseout',  @setOpacity.bind(this, 150))

    @on('mousedown', @onMouseDown, this)

  onMouseDown: (e) ->
    point = e.canvasPoint
    local = @pointToLocal(point)
    console.log("MOUSE DOWN!", local)



  setRadius: (r) ->
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

  draw: (ctx) ->
    r = @getRadius()
    cr = @getControlRadius()

    # FIXME We should monkey patch cocos2d-html5 to support opacity
    ctx.save()
    ctx.globalAlpha = @getOpacity() / 255.0

    # Main Circle
    ctx.beginPath()
    ctx.arc(0, 0, r, 0 , Math.PI * 2, false)
    ctx.fillStyle = '#cb00ff'
    ctx.fill()

    # Resizer
    ctx.beginPath()
    ctx.arc(
      (r - cr) * Math.sin(cc.DEGREES_TO_RADIANS(135))
      (r - cr) * -Math.cos(cc.DEGREES_TO_RADIANS(135))
      cr, 0 , Math.PI * 2, false)
    ctx.fillStyle = '#521f5f'
    ctx.fill()

    ctx.restore()

  toHash: ->
    hash = super
    hash.radius = @_radius
    hash.controlRadius = @_controlRadius

    hash
