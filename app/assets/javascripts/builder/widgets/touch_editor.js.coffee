class App.Builder.Widgets.TouchEditor extends cc.Node

  constructor: (options={}) ->
    super

    @_opacity = 255

    @setRadius(options.radius || 32)
    @setControlRadius(options.controlRadius || 12)

  setRadius: (r) ->
    @_radius = r
    @setContentSize(new cc.Size(@_radius * 2, @_radius * 2))

    this

  setControlRadius: (r) ->
    @_controlRadius = r

    this

  setOpacity: (o) ->
    @_opacity = o

  getOpacity: ->
    @_opacity

  getRadius: ->
    @_radius

  getControlRadius: ->
    @_controlRadius

  draw: (ctx) ->
    r = @getRadius()
    cr = @getControlRadius()

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

  rect: ->
    p = @getPosition()
    s = @getContentSize()
    a = @getAnchorPoint()

    cc.RectMake(
      p.x - s.width  * a.x
      p.y - s.height * a.y
      s.width
      s.height
    )
