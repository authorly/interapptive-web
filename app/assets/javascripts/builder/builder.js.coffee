class Builder extends cc.Layer
  book: null

  constructor: ->
    super
    @setIsTouchEnabled true

    @widgetLayer = new App.Builder.Widgets.WidgetLayer(App.currentWidgets)
    @canvasOverflowLayer = new App.Builder.Widgets.CanvasOverflowLayer()
    @workspaceBorderLayer = new App.Builder.Widgets.WorkspaceBorderLayer()

    #HACK should fix hardcoded CCNode tag (10)
    @addChild(@widgetLayer, 100, 10)
    @addChild(@canvasOverflowLayer, 100, 10)
    @addChild(@workspaceBorderLayer, 100, 15)


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
