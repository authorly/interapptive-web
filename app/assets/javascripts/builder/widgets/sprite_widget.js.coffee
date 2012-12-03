#= require ./widget

COLOR_OUTER_STROKE = 'rgba(15, 79, 168, 0.8)'
COLOR_OUTER_FILL = 'rgba(174, 204, 246, 0.66)'
LINE_WIDTH_OUTER = 12
COLOR_INNER_STROKE = 'rgba(15, 79, 168, 1)'
COLOR_INNER_FILL = 'rgba(255, 255, 255, 1)'
LINE_WIDTH_INNER = 2

##
# A widget that has an associated image.
class App.Builder.Widgets.SpriteWidget extends App.Builder.Widgets.Widget

  constructor: (options={}) ->
    super

    @_url =      options.url
    @_filename = options.filename
    @_zOrder =   options.zOrder
    @_scale =    options.scale
    @_border =   false

    @disableDragging()

    @on 'clickOutside', @setAsInactive

    @sprite = new cc.Sprite
    @_getImage()


  constructorContinuation: (dataUrl) =>
    @sprite.initWithFile(dataUrl)
    @sprite.setScale(@_scale) if @_scale
    @addChild(@sprite)
    @setContentSize(@sprite.getContentSize())
    @trigger('loaded')

    # MOVE ME TO KEYFRA
    # App.storybookJSON.addSprite(App.currentScene(), @sprite)


  isLoaded: ->
    @sprite._texture.complete


  mouseMove: (e) ->
    super
    @_setCursor(if @hasBorder() then 'move' else 'default')

    App.spriteForm.updateXYFormVals()


  mouseOut: ->
    super
    @_setCursor('default')


  doubleClick: ->
    @_setActiveSpriteFromClick()


  setAsActive: (widget = null) ->
    _widget = widget || this

    App.builder.widgetLayer.deselectSpriteWidgets()

    @enableDragging()

    @showBorder()

    App.spriteForm.setActiveSprite(_widget)


  setAsInactive: ->
    @hideBorder()
    @disableDragging()

    App.activeSpritesList.deselectAll()
    App.builder.widgetLayer.clearSelectedWidget()
    App.spriteForm.resetForm()


  enableDragging: ->
    @draggable = true


  disableDragging: ->
    @draggable = false


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


  _getImage: ->
    if @_url.indexOf('/') == 0
      @constructorContinuation(@_url)
    else
      proxy = App.Lib.RemoteDomainProxy.instance()

      proxy.bind 'message', @_from_proxy
      proxy.send
        action: 'load'
        path: @_url


  _from_proxy: (message) =>
    if message.action == 'loaded' && message.path == @_url
      App.Lib.RemoteDomainProxy.instance().unbind 'message', @_from_proxy
      @constructorContinuation(message.bits)


  _setCursor: (cursor) ->
    document.body.style.cursor = cursor


  _setActiveSpriteFromClick: (e) ->
    activeSpriteWidget = App.builder.widgetLayer.widgetAtPoint(e._point)
    return unless activeSpriteWidget

    App.builder.widgetLayer.setSelectedWidget(activeSpriteWidget)
    @setAsActive(activeSpriteWidget)
