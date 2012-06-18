class Builder extends cc.Layer
  isMouseDown: false,
  paragraphText: null,
  backgroundSprite: null

  constructor: ->
    super
    @setIsTouchEnabled true
    true

  ccTouchesBegan: (touches, event) ->
    @isMouseDown = true
    console.log "ccTouchesBegin"

  ccTouchesMoved: (touches, event) ->
    currentPointerPosition = new cc.Point(touches[0].locationInView(0).x, touches[0].locationInView(0).y)
    @backgroundSprite.setPosition currentPointerPosition if touches and @isMouseDown

  ccTouchesEnded: (touches, event) ->
    @isMouseDown = false
    x = parseInt(touches[0].locationInView(0).x)
    y = parseInt(touches[0].locationInView(0).y)
    App.sceneListView.setBackgroundLocation(parseInt(x), parseInt(y))

  ccTouchesCancelled: (touches, event) ->
    console.log "ccTouchesCancelled"

Builder.scene = ->
  scene = cc.Scene.node()
  layer = @node()
  scene.addChild layer
  scene

Builder.node = ->
  ret = new Builder()
  return ret  if ret and ret.init()
  null

window.Builder = Builder
