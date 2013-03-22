class Builder extends cc.Layer
  book: null

  constructor: ->
    super
    @setIsTouchEnabled true

    @widgetLayer = new App.Builder.Widgets.WidgetLayer(App.currentWidgets)
    @canvasOverflowLayer = new App.Builder.Widgets.CanvasOverflowLayer()
    # @widgetStore = new App.Builder.Widgets.WidgetStore
    #HACK should fix hardcoded CCNode tag (10)
    @addChild(@widgetLayer, 100, 10)


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
