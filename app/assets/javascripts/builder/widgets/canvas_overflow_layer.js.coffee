##
# Class for drawing an "overflow" layer around
#  the actual workspace area in the canvas.
#
# The workspace area is what is viewable on a
#  device's screen when compiled.
#
# Overflow panel sizes are calculated dynamically
#  based on the size of the workspace dimensions.
#  The four panels together will automatically
#  fill the area around the workspace, centered.
#
# Panels drawn as follows, around the workspace:
#     ___________
#    |___________|
#    | |       | |
#    | |       | |
#    |_|_______|_|
#    |___________|
#
# Uses rect(x, y, width, height) for panel rectangles.
#
class App.Builder.Widgets.CanvasOverflowLayer extends cc.Layer
  COLOR_OUTER_STROKE = 'rgba(0, 0, 0, 1)'

  COLOR_OUTER_FILL = 'rgba(174, 204, 246, 0.66)'

  OVERFLOW_LAYER_COLOR = 'rgba(190, 190, 190, 0.25)'

  LINE_WIDTH_OUTER = 2


  constructor: ->
    super

    @canvasWidth = $(cc.canvas).attr('width')
    @canvasHeight = $(cc.canvas).attr('height')
    @horizontalPanelHeight = (@canvasHeight - App.Config.dimensions.height) / 2
    @verticalPanelWidth = (@canvasWidth - App.Config.dimensions.width) / 2


  draw: (ctx) ->
    ctx.save()
    ctx.globalAlpha = 255 / 255.0

    @drawPanels(ctx)
    @drawCanvasBorder(ctx)

    ctx.restore()


  drawCanvasBorder: (ctx) ->
    ctx.beginPath()

    ctx.rect(
      App.Config.dimensions.width / -2,
      App.Config.dimensions.height / -2,
      App.Config.dimensions.width,
      App.Config.dimensions.height
    )

    ctx.stroke()
    ctx.beginPath()
    ctx.fillStyle = COLOR_OUTER_STROKE
    ctx.fill()


  drawPanels: (ctx) ->
    ctx.beginPath()
    ctx.fillStyle = OVERFLOW_LAYER_COLOR
    ctx.fill()

    # Top panel
    ctx.rect(
      @canvasWidth / -2,
      App.Config.dimensions.height / -2  - @horizontalPanelHeight,
      @canvasWidth,
      @horizontalPanelHeight
    )

    # Bottom panel
    ctx.rect(
      @canvasWidth / -2,
      App.Config.dimensions.height / 2,
      @canvasWidth,
      @horizontalPanelHeight
    )

    # Left panel
    ctx.rect(
      App.Config.dimensions.width / -2 - @verticalPanelWidth,
      App.Config.dimensions.height / -2,
      @verticalPanelWidth,
      App.Config.dimensions.height
    )

    # Right panel
    ctx.rect(
      App.Config.dimensions.width  / 2,
      App.Config.dimensions.height / -2,
      @verticalPanelWidth,
      App.Config.dimensions.height
    )

    ctx.fill()

