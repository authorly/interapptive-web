#= require ./widget

COLOR_OUTER_STROKE = 'rgba(15, 79, 168, 0.8)'
COLOR_OUTER_FILL = 'rgba(174, 204, 246, 0.66)'
LINE_WIDTH_OUTER = 12
COLOR_INNER_STROKE = 'rgba(15, 79, 168, 1)'
COLOR_INNER_FILL = 'rgba(255, 255, 255, 1)'
LINE_WIDTH_INNER = 2

class App.Builder.Widgets.SpriteWidget extends App.Builder.Widgets.Widget
  retention: 'scene'
  retentionMutability: true # This object is independent across keyframes.

  @newFromHash: (hash) ->
    widget = new this(hash)

    # Why this next line, given that the constructor does this already?
    if hash.zOrder then widget._zOrder = hash.zOrder
    key = "keyframe_" + App.currentKeyframe().get('id')
    widget.setPosition(widget.getPosition()) if widget.hasKeyframeDatum(App.currentKeyframe())

    if hash.id >= NEXT_WIDGET_ID
      NEXT_WIDGET_ID = hash.id + 1

    return widget


  constructor: (options={}) ->
    super

    @_keyframeData = options.keyframeData ? App.keyframeList().collection.reduce(((hsh, keyframe) => hsh["keyframe_" + keyframe.get('id')] = {scale: 1.0, x: 300, y: 400}; hsh), {})
    @_url       = options.url
    @_filename  = options.filename
    @_zOrder    = options.zOrder
    @_border    = false

    @disableDragging()

    @on 'dblclick',     @setActiveSpriteFromClick
    @on 'clickOutside', @setAsInactive
    @on 'mousemove',    @mouseMove
    @on "mouseover",    @mouseOver
    @on "mouseout",     @mouseOut

    @sprite = new cc.Sprite
    @getImage()


  constructorContinuation: (dataUrl) =>
    cc.TextureCache.sharedTextureCache().addImageAsync @_url, this, =>
      @sprite.initWithFile(@_url)
      @setScale(@currentKeyframe().scale) if @currentKeyframe()?.scale
      @addChild(@sprite)
      @setContentSize(@sprite.getContentSize())
      @trigger('loaded')

    # TODO: MOVE ME TO KEYFRA
    # ^
    # That is what Chris wrote. I'm not sure what he was trying to do with this.
    # I would imagine he wants to move it somewhere, but he didn't finish his 
    # thought, and without this, the spriteForm breaks.
    # Hence, I have uncommented it.
    #
    # - Rob
    App.storybookJSON.addSprite(App.currentScene(), @)

  currentKeyframe: =>
    id = App.currentKeyframe().get('id')
    @_keyframeData["keyframe_#{id}"]

  hasKeyframeDatum: (keyframe) =>
    "keyframe_#{keyframe.get('id')}" in _.keys(@_keyframeData)

  addKeyframeDatum: (keyframe, content) =>
    @_keyframeData["keyframe_#{keyframe.get('id')}"] = content

  removeKeyframeDatum: (keyframe) =>
    delete @_keyframeData["keyframe_#{keyframe.get('id')}"]

  copyKeyframeDatum: (newKeyframe, oldKeyframe) =>
    @_keyframeData["keyframe_#{newKeyframe.get('id')}"] = _.clone(@_keyframeData["keyframe_#{oldKeyframe.get('id')}"])


  reloadKeyframeInfo: =>
    @setPosition(new cc.Point(@currentKeyframe().x, @currentKeyframe().y))
    @setScale(@currentKeyframe().scale)
    @setContentSize(@sprite.getContentSize())
    @trigger('loaded')

  isLoaded: ->
    @sprite._texture.complete


  mouseMove: (e) ->
    @setCursor(if @hasBorder() then 'move' else 'default')

    App.spriteForm.updateXYFormVals()

    # @on 'dblclick',     @setActiveSpriteFromClick
    # @on 'clickOutside', @setAsInactive


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
    hash = {}
    hash.id = @id
    hash.type = Object.getPrototypeOf(this).constructor.name
    hash.retention = @retention
    hash.retentionMutability = @retentionMutability

    hash.filename = @_filename
    hash.url =      @_url

    # This is now part of the keyframes hash.
    # hash.scale =    @_scale

    hash.zOrder =   @_zOrder
    hash.keyframeData = @_keyframeData

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
    @currentKeyframe().scale = parseFloat(scale)
    @sprite.setScale(scale)

  getScale: ->
    @currentKeyframe().scale

  getPosition: =>
    new cc.Point(@currentKeyframe().x, @currentKeyframe().y)

  getPositionX: =>
    @currentKeyframe().x

  getPositionY: =>
    @currentKeyframe().y

  setPosition: (newPosOrxValue, triggerEvent = true) =>
    @currentKeyframe().x = parseInt(newPosOrxValue.x)
    @currentKeyframe().y = parseInt(newPosOrxValue.y)
    super

  setPositionX: (x) =>
    @currentKeyframe().x = parseInt(x)
    super

  setPositionY: (y) =>
    @currentKeyframe().y = parseInt(y)
    super

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


  getImage: ->
    proxy = App.Lib.RemoteDomainProxy.instance()

    proxy.bind 'message', @from_proxy
    proxy.send
      action: 'load'
      path: @_url


  from_proxy: (message) =>
    if message.action == 'loaded' && message.path == @_url
      App.Lib.RemoteDomainProxy.instance().unbind 'message', @from_proxy
      @constructorContinuation(message.bits)
