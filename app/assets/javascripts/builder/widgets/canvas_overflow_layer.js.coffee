class App.Builder.Widgets.CanvasOverflowLayer extends cc.Node
  COLOR_OUTER_STROKE: 'rgba(15, 79, 168, 0.8)'
  COLOR_OUTER_FILL:   'rgba(174, 204, 246, 0.66)'
  COLOR_INNER_STROKE: 'rgba(15, 79, 168, 1)'
  COLOR_INNER_FILL:   'rgba(255, 255, 255, 1)'
  LINE_WIDTH_OUTER:   14
  LINE_WIDTH_INNER:   2

  constructor: ->
    super


  draw: (ctx) ->
    console.log('called')
    # FIXME We should monkey patch cocos2d-html5 to support opacity
    ctx.save()
    ctx.globalAlpha = 255 / 255.0
 
    ctx.beginPath()
 
    ctx.rect(-512, -384, 1024, 768)
 
    ctx.strokeStyle = @COLOR_OUTER_STROKE
    ctx.lineWidth = @LINE_WIDTH_OUTER
    ctx.stroke()
 
    ctx.beginPath()
    ctx.fillStyle = @COLOR_OUTER_FILL
    ctx.fill()
 
    ctx.restore()
