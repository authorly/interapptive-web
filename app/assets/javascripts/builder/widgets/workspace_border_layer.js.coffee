##
# Class for drawing a border around the workspace
#
class App.Builder.Widgets.WorkspaceBorderLayer extends cc.Layer
  COLOR_OUTER_FILL = 'rgba(174, 204, 246, 0.1)'

  OVERFLOW_LAYER_COLOR = 'rgba(190, 190, 190, 1)'

  BORDER_COLOR = 'rgba(75, 215, 110, 0)'

  BORDER_COLOR_HIGHLIGHTED = 'rgba(75, 215, 110, 1)'

  LINE_WIDTH_OUTER = 2


  constructor: ->
    super

    @borderColor = BORDER_COLOR

    App.vent.on 'assetDrag-start', (=> @borderColor = BORDER_COLOR_HIGHLIGHTED)
    App.vent.on 'assetDrag-stop',  (=> @borderColor = BORDER_COLOR)


  draw: (ctx) ->
    ctx.save()
    ctx.globalAlpha = 255 / 255.0

    @drawCanvasBorder(ctx)

    ctx.restore()


  drawCanvasBorder: (ctx) =>
    ctx.beginPath()

    ctx.rect(
      App.Config.dimensions.width / -2,
      App.Config.dimensions.height / -2,
      App.Config.dimensions.width,
      App.Config.dimensions.height
    )

    ctx.strokeStyle = @borderColor
    ctx.lineWidth = LINE_WIDTH_OUTER
    ctx.stroke()
    ctx.beginPath()
    ctx.fillStyle = COLOR_OUTER_FILL
    ctx.fill()
