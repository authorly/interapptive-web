class Builder extends cc.Layer
  isMouseDown: false
  backgroundSprite: null

  constructor: ->
    super
    @setIsTouchEnabled true

    @widgetLayer = new App.Builder.Widgets.WidgetLayer
    #@addChild(@widgetLayer, 100)

    # Test touch widget
    #touch = new App.Builder.Widgets.TouchWidget
    #touch.setPosition(new cc.Point(350, 300))
    #@widgetLayer.addWidget(touch)

    #touch = new App.Builder.Widgets.TouchWidget
    #touch.setPosition(new cc.Point(450, 100))
    #@widgetLayer.addWidget(touch)

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
