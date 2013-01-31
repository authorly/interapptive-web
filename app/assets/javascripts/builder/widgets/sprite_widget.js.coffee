#= require ./widget

##
# Show a SpriteWidget as a cc.Sprite.
class App.Builder.Widgets.SpriteWidget extends App.Builder.Widgets.Widget
  COLOR_OUTER_STROKE: 'rgba(15, 79, 168, 0.8)'
  COLOR_OUTER_FILL:   'rgba(174, 204, 246, 0.66)'
  COLOR_INNER_STROKE: 'rgba(15, 79, 168, 1)'
  COLOR_INNER_FILL:   'rgba(255, 255, 255, 1)'
  LINE_WIDTH_OUTER:   12
  LINE_WIDTH_INNER:   2

  constructor: (options) ->
    super

    @_border = false

    # @model - is set by the super constructor
    @sprite = new App.Builder.Widgets.Lib.Sprite(options)

    @disableDragging()

    @on 'clickOutside',       @setAsInactive
    @on 'change:orientation', @updateOrientation
    @on 'dblclick',           @doubleClick

    @_getImage()


  constructorContinuation: (dataUrl) =>
    @model.dataUrl = dataUrl
    cc.TextureCache.sharedTextureCache().addImageAsync @model.dataUrl, @, =>
      @sprite.initWithFile @model.dataUrl

      currentOrientation = @model.getOrientationFor(App.currentSelection.get('keyframe'))
      @applyOrientation(currentOrientation)

      position = currentOrientation.get('position')
      @sprite.setPosition(new cc.Point(position.x, position.y))
      @sprite.setScale(parseFloat(currentOrientation.get('scale')))
      @setContentSize(@sprite.getContentSize())
      #@setPosition(@sprite.getPosition())
      @addChild(@sprite)

      # TODO RFCTR bring this back
      # window.setTimeout @triggerLoaded, 0


  applyOrientation: (orientation) ->
    position = orientation.get('position')

    @sprite.setPosition(new cc.Point(position.x, position.y))
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


  # updateOrientation: =>
    # keyframe = App.currentKeyframe()
    # orientationWidget = _.detect @orientations(), (orientation) ->
      # orientation.keyframe.id == keyframe.id
    # orientationWidget.point = @getPosition()
    # orientationWidget.update()


  # orientations: ->
    # if arguments.length > 0
      # @_orientations = []
      # _.each(arguments[0], (orientation) =>
        # throw new Error("orientations of a SpriteWidget must be a App.Builder.Widgets.SpriteOrientationWidget") unless (orientation instanceof App.Builder.Widgets.SpriteOrientationWidget)
        # @_orientations.push(orientation)
      # )
    # else
      # @_orientations


  # orientationsToHash: ->
    # _.map(@orientations(), (orientation) -> orientation.toHash())




  # triggerLoaded: =>
    # if @isLoaded()
      # @setContentSize(@sprite.getContentSize())
    # else
      # window.setTimeout @triggerLoaded, 200

  # #
  # # NOTE:
  # #    There addImageSync() from Cocos2d, used in the constructor,
  # #    may be worth using instead of this?
  # #
  # isLoaded: ->
    # size = @sprite.getContentSize()
    # @sprite._texture.complete && (size.width + size.height > 0)


  # hasOrientationForKeyframe: (keyframe) =>
    # _.any(@orientations(), (orientation) -> orientation.keyframe is keyframe)


  # mouseMove: (e) ->
    # super
    # @_setCursor(if @hasBorder() then 'move' else 'default')


  # mouseOut: ->
    # super
    # @_setCursor('default')


  doubleClick: (e) ->
    @_setActiveSpriteFromClick(e)


  setAsActive: (widget = null) ->
    _widget = widget || this

    App.vent.trigger 'sprite_widget:select', _widget

    @enableDragging()
    @showBorder()


  # setAsInactive: ->
    # App.vent.trigger 'sprite_widget:deselect'

    # @hideBorder()
    # @disableDragging()


    # # RFCTR:
    # #     Needs ventilation
    # App.builder.widgetLayer.clearSelectedWidget()
    # # Trigger the below w vent, makes it work
    # # App.spriteForm.resetForm()


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

  # TODO RFCTR this belong to the model
  # toHash: ->
    # hash                      =    {}
    # hash.id                   =    @id
    # hash.type                 =    @type
    # hash.retention            =    @retention
    # hash.retentionMutability  =    @retentionMutability
    # hash.filename             =    @sprite.filename
    # hash.url                  =    @sprite.url
    # hash.zOrder               =    @sprite.zOrder
    # hash.orientations         =    @orientationsToHash()
    # hash

  # toSceneHash: ->
    # _.pick(@toHash(), 'id', 'type', 'retention', 'retentionMutability', 'filename', 'url', 'zOrder')

  # setZOrder: (z) ->
    # @sprite.zOrder = z

  # getZOrder: ->
    # @sprite.zOrder

  # getUrl: ->
    # @sprite.url

  # getFilename: ->
    # @sprite.filename


  # getScaleForKeyframe: ->
    # keyframe = App.currentSelection.get('keyframe') unless keyframe?
    # @keyframe.getOrientationForWidget(@).scale



  # getOrientationForKeyframe: ->
    # keyframe = arguments[0] || App.currentSelection.get('keyframe')
    # orientation = null
    # # TODO This is a dirty fix. This method should be in the Widget model, and
    # # not depend on App.currentKeyframe()
    # if keyframe?
      # orientation = _.find(@orientations(), (p) -> p.keyframe.id == keyframe.id)
    # orientation || @orientations()[0]

  # setPositionX: (x) =>
    # #@currentKeyframe().x = parseInt(x)
    # #super

  # setPositionY: (y) =>
    # #@currentKeyframe().y = parseInt(y)
    # #super

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
    ctx.strokeStyle = @COLOR_OUTER_STROKE
    ctx.lineWidth = @LINE_WIDTH_OUTER
    ctx.stroke()

    ctx.beginPath()
    ctx.fillStyle = @COLOR_OUTER_FILL
    ctx.fill()

    ctx.restore()

  # # save() should probably be named create() because
  # # it always creates a new SpriteWidget. There should
  # # also be update() and destroy() as well.
  # save: ->
    # widgets = @scene().get('widgets') || []
    # widgets.push(@toSceneHash())
    # @scene().set('widgets', widgets)
    # @scene().save({},
      # success: => @updateStorybookJSON()
      # error:   => @couldNotSave()
    # )

  # update: ->
    # throw new Error("Not implemented")

  # destroy: ->
    # throw new Error("Not implemented")

  # updateStorybookJSON: ->
    # App.storybookJSON.addSprite(this)
    # App.builder.widgetStore.addWidget(this)

    # # OPTIMIZE: Following will make Ajasx requests equal
    # # to the number of position to save.
    # # Perhaps write a way to save multiple orientations in
    # # one request.
    # _.each(@orientations(), (position) -> position.save())

  # couldNotSave: ->
    # console.log('SpriteWidget did not save')

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


  from_proxy: (message) =>
    if message.action == 'loaded' && message.path == @model.get('url')
      App.Lib.RemoteDomainProxy.instance().unbind 'message', @from_proxy
      @constructorContinuation(message.bits)


  # _setCursor: (cursor) ->
    # document.body.style.cursor = cursor


  # RFCTR
  #     This is all very bad (WIP), needs ventilation/decoupling
  _setActiveSpriteFromClick: (e) ->
    activeSpriteWidget = App.builder.widgetLayer.widgetAtPoint(e._point)
    return unless activeSpriteWidget


    App.builder.widgetLayer.setSelectedWidget(activeSpriteWidget)
    @setAsActive(activeSpriteWidget)
