##
# Class for drawing a border around the workspace
#
class App.Builder.Widgets.WorkspaceBorderLayer extends cc.Layer
  COLOR_OUTER_FILL = 'rgba(174, 204, 246, 0.1)'

  BORDER_COLOR = 'rgba(0, 0, 0, 1)'

  BORDER_COLOR_HIGHLIGHTED = 'rgba(75, 215, 110, 1)'

  LINE_WIDTH_OUTER = 2


  constructor: ->
    super

    @borderColor = BORDER_COLOR
    @canvasWidth = $(cc.canvas).attr('width')
    @canvasHeight = $(cc.canvas).attr('height')
    @horizontalPanelHeight = (@canvasHeight - App.Config.dimensions.height) / 2
    @verticalPanelWidth = (@canvasWidth - App.Config.dimensions.width) / 2

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
      @verticalPanelWidth,
      -@canvasHeight + @horizontalPanelHeight,
      App.Config.dimensions.width,
      App.Config.dimensions.height
    )

    ctx.strokeStyle = @borderColor
    ctx.lineWidth = LINE_WIDTH_OUTER
    ctx.stroke()
    ctx.beginPath()
    ctx.fillStyle = COLOR_OUTER_FILL
    ctx.fill()
