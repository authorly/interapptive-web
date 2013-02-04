#= require ./widget

##
# Show a SpriteWidget as a cc.Sprite.
#
# Graphical properties:
# _border
#
class App.Builder.Widgets.SpriteWidget extends App.Builder.Widgets.Widget
  COLOR_OUTER_STROKE: 'rgba(15, 79, 168, 0.8)'
  COLOR_OUTER_FILL:   'rgba(174, 204, 246, 0.66)'
  COLOR_INNER_STROKE: 'rgba(15, 79, 168, 1)'
  COLOR_INNER_FILL:   'rgba(255, 255, 255, 1)'
  LINE_WIDTH_OUTER:   14
  LINE_WIDTH_INNER:   2

  constructor: (options) ->
    super

    @_border = false

    # @model - is set by the super constructor
    @sprite = new App.Builder.Widgets.Lib.Sprite(options)

    @on 'change:orientation', @updateOrientation
    @on 'deselect body:click',@deselect
    @on 'double_click',       @doubleClick
    @on 'mousemove',          @mouseMove

    App.vent.on 'canvas:click_outside', @deselect

    @_getImage()


  constructorContinuation: (dataUrl) =>
    @model.dataUrl = dataUrl
    cc.TextureCache.sharedTextureCache().addImageAsync @model.dataUrl, @, =>
      @sprite.initWithFile @model.dataUrl

      currentOrientation = @model.getOrientationFor(App.currentSelection.get('keyframe'))
      @applyOrientation(currentOrientation)

      @setScale(parseFloat(currentOrientation.get('scale')))
      @addChild(@sprite)

      position = currentOrientation.get('position')
      @setPosition(new cc.Point(position.x, position.y))

      window.setTimeout @triggerLoaded, 0


  triggerLoaded: =>
    if @isLoaded()
      @setContentSize(@sprite.getContentSize())
    else
      window.setTimeout @triggerLoaded, 200


  isLoaded: ->
    size = @sprite.getContentSize()
    @sprite._texture.complete && (size.width + size.height > 0)


  mouseMove: ->
    @_setCursor('move')


  doubleClick: (event) ->
    @_setActiveSpriteFromClick(event)


  applyOrientation: (orientation) ->
    position = orientation.get('position')

    @setPosition(new cc.Point(position.x, position.y))
    scale = parseFloat(orientation.get('scale'))
    @sprite.setScale(scale)


  # TODO RFCTR this must be a change to the model, on which this
  # view will react
  updateOrientation: =>
    keyframe = App.currentSelection.get('keyframe')
    orientationWidget = _.detect @orientations(), (orientation) ->
      orientation.keyframe.id == keyframe.id
    orientationWidget.point = @getPosition()
    orientationWidget.update()


  select: (widget = null) =>
    _widget = widget || this

    App.vent.trigger 'sprite_widget:select', _widget

    @showBorder()


  deselect: =>
    @hideBorder()


  # RFCTR - Move to widget layer
  mouseOver: (e) ->
    @_setCursor('move')


  # RFCTR - Move to widget layer
  mouseOut: ->
    @_setCursor('default')


  showBorder: =>
    @_border = true


  hideBorder: =>
    @_border = false


  hasBorder: =>
    @_border


  draw: (ctx) ->
    return unless @hasBorder()

    # FIXME We should monkey patch cocos2d-html5 to support opacity
    ctx.save()
    ctx.globalAlpha = 255 / 255.0

    ctx.beginPath()

    x =     (@sprite.getContentSize().width * @sprite.getScale()) * (@sprite.getAnchorPoint().x * -1)
    y =     (@sprite.getContentSize().height * @sprite.getScale()) * (@sprite.getAnchorPoint().x * -1)
    width =  @sprite.getContentSize().width * @sprite.getScale()
    height = @sprite.getContentSize().height * @sprite.getScale()
    ctx.rect(x, y, width, height)

    ctx.strokeStyle = @COLOR_OUTER_STROKE
    ctx.lineWidth = @LINE_WIDTH_OUTER
    ctx.stroke()

    ctx.beginPath()
    ctx.fillStyle = @COLOR_OUTER_FILL
    ctx.fill()

    ctx.restore()


  from_proxy: (message) =>
    if message.action == 'loaded' && message.path == @model.get('url')
      App.Lib.RemoteDomainProxy.instance().unbind 'message', @from_proxy
      @constructorContinuation(message.bits)


  _getImage: ->
    url = @model.get('url')
    if url.indexOf('/') == 0
      @constructorContinuation(url)
    else
      proxy = App.Lib.RemoteDomainProxy.instance()

      proxy.bind 'message', @from_proxy
      proxy.send
        action: 'load'
        path:   url


  _setCursor: (cursor) ->
    document.body.style.cursor = cursor


  # RFCTR!!!!
  _setActiveSpriteFromClick: (event) ->
    activeSpriteWidget = App.builder.widgetLayer.widgetAtPoint(event._point)
    return unless activeSpriteWidget

    # RFCTR  Needs ventilation
    App.builder.widgetLayer.setSelectedWidget(activeSpriteWidget)
    @select(activeSpriteWidget)
