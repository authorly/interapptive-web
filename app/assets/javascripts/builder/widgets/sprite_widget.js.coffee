#= require ./widget

COLOR_OUTER_STROKE = 'rgba(15, 79, 168, 0.8)'
COLOR_OUTER_FILL = 'rgba(174, 204, 246, 0.66)'
LINE_WIDTH_OUTER = 12
COLOR_INNER_STROKE = 'rgba(15, 79, 168, 1)'
COLOR_INNER_FILL = 'rgba(255, 255, 255, 1)'
LINE_WIDTH_INNER = 2

class App.Builder.Widgets.SpriteWidget extends App.Builder.Widgets.Widget

  constructor: (options={}) ->
    super

    @_url =      options.url
    @_filename = options.filename
    @_zOrder =   options.zOrder
    @_scale =    options.scale
    @_border =   false

    @sprite = new cc.Sprite
    @sprite.initWithFile(@_url)
    @sprite.setScale(@_scale) if @_scale
    @addChild(@sprite)
    @setContentSize(@sprite.getContentSize())

    @disableDragging()

    @on 'dblclick',     @setActiveSpriteFromClick
    @on 'clickOutside', @setAsInactive
    @on 'mousemove',    @mouseMove
    @on "mouseover",    @mouseOver
    @on "mouseout",     @mouseOut


  mouseMove: (e) ->
    @setCursor(if @hasBorder() then 'move' else 'default')

    App.spriteForm.updateXYFormVals()


  mouseOut: ->
    @setCursor('default')


  setCursor: (cursor) ->
    document.body.style.cursor = cursor


  setAsInactive: ->
    @hideBorder()

    @disableDragging()

    App.activeSpritesList.deselectAll()
    App.builder.widgetLayer.clearSelectedWidget()
    App.spriteForm.resetForm()


  disableDragging: ->
    @draggable = false


  enableDragging: ->
    @draggable = true


  setActiveSpriteFromClick: (e) ->
    activeSpriteWidget = App.builder.widgetLayer.widgetAtPoint(e._point)
    return unless activeSpriteWidget

    App.builder.widgetLayer.setSelectedWidget(activeSpriteWidget)
    @setAsActive(activeSpriteWidget)


  setAsActive: (widget = null) ->
    _widget = widget || this

    App.builder.widgetLayer.deselectSpriteWidgets()

    @enableDragging()

    @showBorder()

    App.spriteForm.setActiveSprite(_widget)


  showBorder: ->
    @_border = true


  hideBorder: ->
    @_border = false


  hasBorder: ->
    @_border


  toHash: ->
    hash = super

    hash.filename = @_filename
    hash.url =      @_url
    hash.scale =    @_scale
    hash.zOrder =   @_zOrder

    hash


  setZOrder: (z) ->
    @_zOrder = z


  getZOrder: ->
    @_zOrder


  getUrl: ->
    @_url


  getFilename: ->
    @_filename


  setScale: (scale) ->
    @_scale = scale
    @sprite.setScale(scale)


  getScale: ->
    @_scale


  draw: (ctx) ->
    return unless @hasBorder()

    # FIXME We should monkey patch cocos2d-html5 to support opacity
    ctx.save()
    ctx.globalAlpha = 255 / 255.0

    ctx.beginPath()
    _x =     (@sprite.getContentSize().width * @sprite.getScale()) * -0.5
    _y =     (@sprite.getContentSize().height * @sprite.getScale()) * -0.5
    _width =  @sprite.getContentSize().width * @sprite.getScale()
    _height = @sprite.getContentSize().height * @sprite.getScale()

    ctx.rect(_x, _y, _width, _height)
    ctx.strokeStyle = COLOR_OUTER_STROKE
    ctx.lineWidth = LINE_WIDTH_OUTER
    ctx.stroke()

    ctx.beginPath()
    ctx.fillStyle = COLOR_OUTER_FILL
    ctx.fill()

    ctx.restore()