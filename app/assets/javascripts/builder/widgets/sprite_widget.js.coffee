#= require ./widget

##
# A widget that has an associated image.
#
# It belongs to a scene, and it can have a different position or scale in
# each of the keyframes of that scene. SpriteOrientationWidget is the association
# between a SpriteWidget and a Keyframe; it stores the position and scale of the
# SpriteWidget in that Keyframe.
# TODO RFCTR extract a Backbone model out of this.
class App.Builder.Widgets.SpriteWidget extends App.Builder.Widgets.Widget
  COLOR_OUTER_STROKE: 'rgba(15, 79, 168, 0.8)'
  COLOR_OUTER_FILL: 'rgba(174, 204, 246, 0.66)'
  LINE_WIDTH_OUTER: 12
  COLOR_INNER_STROKE: 'rgba(15, 79, 168, 1)'
  COLOR_INNER_FILL: 'rgba(255, 255, 255, 1)'
  LINE_WIDTH_INNER: 2

  constructor: (options) ->
    super

    @sprite = new App.Builder.Widgets.Lib.Sprite(options)

    @disableDragging()

    @on 'clickOutside',       @setAsInactive
    @on 'change:orientation', @updateOrientation

    @_getImage()


  # TODO RFCTR this must be a change to the model, on which this
  # view will react
  updateOrientation: =>
    keyframe = App.currentSelection.get('keyframe')
    orientationWidget = _.detect @orientations(), (orientation) ->
      orientation.keyframe.id == keyframe.id
    orientationWidget.point = @getPosition()
    orientationWidget.update()


  constructorContinuation: (dataUrl) =>
    @model.set url: dataUrl
    cc.TextureCache.sharedTextureCache().addImageAsync @model.get('url'), @, =>
      @sprite.initWithFile @model.get('url')

      currentOrientation = @model.getOrientationFor(App.currentSelection.get('keyframe'))
      @setPosition currentOrientation.get('position')
      @setScale    currentOrientation.get('scale')

      @addChild(@sprite)
      window.setTimeout @triggerLoaded, 0


  setScale: (scale) ->
    @sprite.setScale parseFloat(scale)




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


  # setAsActive: (widget = null) ->
    # _widget = widget || this

    # App.vent.trigger 'sprite_widget:select', _widget

    # #
    # # RFCTR: Needs ventilation
    # #     App.vent.trigger 'sprite_widget:selected'
    # #     App.vent.on 'sprite_widget:selected', @deselectSpriteWidgets
    # #
    # App.builder.widgetLayer.deselectSpriteWidgets()

    # @enableDragging()
    # @showBorder()


  # setAsInactive: ->
    # App.vent.trigger 'sprite_widget:deselect'

    # @hideBorder()
    # @disableDragging()


    # # RFCTR:
    # #     Needs ventilation
    # App.builder.widgetLayer.clearSelectedWidget()
    # # Trigger the below w vent, makes it work
    # # App.spriteForm.resetForm()


  # enableDragging: ->
    # @draggable = true


  disableDragging: ->
    @draggable = false


  # showBorder: ->
    # @scene.border = true


  # hideBorder: ->
    # @scene.border = false


  # hasBorder: ->
    # @scene.border

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

  # draw: (ctx) ->
    # return unless @hasBorder()

    # # FIXME We should monkey patch cocos2d-html5 to support opacity
    # ctx.save()
    # ctx.globalAlpha = 255 / 255.0

    # ctx.beginPath()
    # _x =     (@sprite.getContentSize().width * @sprite.getScale()) * -0.5
    # _y =     (@sprite.getContentSize().height * @sprite.getScale()) * -0.5
    # _width =  @sprite.getContentSize().width * @sprite.getScale()
    # _height = @sprite.getContentSize().height * @sprite.getScale()

    # ctx.rect(_x, _y, _width, _height)
    # ctx.strokeStyle = COLOR_OUTER_STROKE
    # ctx.lineWidth = LINE_WIDTH_OUTER
    # ctx.stroke()

    # ctx.beginPath()
    # ctx.fillStyle = COLOR_OUTER_FILL
    # ctx.fill()

    # ctx.restore()

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
    if message.action == 'loaded' && message.path == @model.url()
      App.Lib.RemoteDomainProxy.instance().unbind 'message', @from_proxy
      @constructorContinuation(message.bits)


  # _setCursor: (cursor) ->
    # document.body.style.cursor = cursor


  # _setActiveSpriteFromClick: (e) ->
    # activeSpriteWidget = App.builder.widgetLayer.widgetAtPoint(e._point)
    # return unless activeSpriteWidget

    # App.builder.widgetLayer.setSelectedWidget(activeSpriteWidget)
    # @setAsActive(activeSpriteWidget)
