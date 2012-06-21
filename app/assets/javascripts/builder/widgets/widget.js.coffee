class App.Builder.Widgets.Widget extends cc.Node
  constructor: (options={}) ->
    super

    @_opacity = 255

  setOpacity: (o) ->
    @_opacity = o

  getOpacity: ->
    @_opacity

  rect: ->
    p = @getPosition()
    s = @getContentSize()
    a = @getAnchorPoint()

    cc.RectMake(
      p.x - s.width  * a.x
      p.y - s.height * a.y
      s.width
      s.height
    )
