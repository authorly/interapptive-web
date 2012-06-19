class Builder extends cc.Layer
  isMouseDown: false
  backgroundSprite: null

  constructor: ->
    super
    # this.addChild(new App.Builder.Widgets.TouchEditorLayer, 100)
    @setIsTouchEnabled true
    true

  ccTouchesBegan: (touches, event) ->
    @isMouseDown = true

  ccTouchesMoved: (touches, event) ->
    currentPointerPosition = new cc.Point(touches[0].locationInView(0).x, touches[0].locationInView(0).y)
    @backgroundSprite.setPosition currentPointerPosition if touches and @isMouseDown

  ccTouchesEnded: (touches, event) ->
    @isMouseDown = false
    touchLocation = touches[0].locationInView(0)
    App.keyframeListView.setBackgroundPosition(parseInt(touchLocation.x), parseInt(touchLocation.y))

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
