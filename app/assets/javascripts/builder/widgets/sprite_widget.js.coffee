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

    @sprite = new App.Builder.Widgets.Lib.Sprite(options)

    @_getImage()

    App.vent.on 'scale:sprite', @adjustSpriteScale


  adjustSpriteScale: (val) =>
    @setScale(parseFloat(val))


  constructorContinuation: (dataUrl) =>
    @model.dataUrl = dataUrl

    cc.TextureCache.sharedTextureCache().addImageAsync @model.dataUrl, @, =>
      @sprite.initWithFile @model.dataUrl

      currentOrientation = @model.getOrientationFor(App.currentSelection.get('keyframe'))
      currentOrientation.on('change:scale', @_changeScale, @)
      @applyOrientation(currentOrientation)

      @setScale(parseFloat(currentOrientation.get('scale')))
      @addChild(@sprite)

      window.setTimeout @checkLoadedStatus, 0


  checkLoadedStatus: =>
    if @isLoaded()
      @setContentSize @sprite.getContentSize()
      App.vent.trigger 'load:sprite'
    else
      window.setTimeout @checkLoadedStatus, 200


  # NOTE:
  #    There addImageSync() from Cocos2d, used in the constructor,
  #    may be worth using instead of this?
  #
  isLoaded: ->
    size = @sprite.getContentSize()
    @sprite._texture.complete && (size.width + size.height > 0)


  applyOrientation: (orientation) ->
    @currentOrientation = orientation

    position = orientation.get('position')

    @setPosition(new cc.Point(position.x, position.y))
    scale = parseFloat(orientation.get('scale'))
    @sprite.setScale(scale)
    @setScale(scale)


  select: ->
    @showBorder()


  deselect: ->
    @hideBorder()


  mouseOver: ->
    @parent.setCursor('move')
    @showBorder()


  mouseOut: ->
    @parent.setCursor('default')
    @hideBorder()


  showBorder: ->
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


  _changeScale: (__, scale) ->
    @sprite.setScale(parseFloat(scale))


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
