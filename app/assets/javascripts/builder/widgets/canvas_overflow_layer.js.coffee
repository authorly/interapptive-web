class App.Builder.Widgets.CanvasOverflowLayer extends cc.Layer
  COLOR_OUTER_STROKE: 'rgba(0, 0, 0, 0.1)'

  COLOR_OUTER_FILL: 'rgba(174, 204, 246, 0.66)'

  COLOR_INNER_STROKE: 'rgba(15, 79, 168, 0.9)'

  COLOR_INNER_FILL: 'rgba(190, 190, 190, 0.75)'

  LINE_WIDTH_OUTER: 2

  LINE_WIDTH_INNER: 2


  constructor: ->
    super


  draw: (ctx) ->
    ctx.save()
    ctx.globalAlpha = 255 / 255.0

    @drawCanvasBorder(ctx)
    @drawPanels(ctx)

    ctx.restore()


  drawCanvasBorder: (ctx) ->
    ctx.beginPath()
    ctx.rect(-512, -384, 1024, 768)
    ctx.strokeStyle = @COLOR_OUTER_STROKE
    ctx.lineWidth = @LINE_WIDTH_OUTER
    ctx.stroke()
    ctx.beginPath()
    ctx.fillStyle = @COLOR_OUTER_FILL
    ctx.fill()


  drawPanels: (ctx) ->
    ctx.beginPath()
    ctx.fillStyle = @COLOR_INNER_FILL
    ctx.fill()

    # Bottom panel
    ctx.rect(-812, 384, 1824, 400)

    # Top panel
    ctx.rect(-812, -784, 1824, 400)

    # Left panel
    ctx.rect(-812, -384, 300, 768)

    # Right panel
    ctx.rect(512, -384, 300, 768)

    ctx.fillStyle = @COLOR_INNER_FILL
    ctx.fill()

