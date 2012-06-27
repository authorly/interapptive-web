class App.Builder.Widgets.Widget extends cc.Node
  constructor: (options={}) ->
    super
    _.extend(this, Backbone.Events)

    @_opacity = 255

  setOpacity: (o) ->
    @_opacity = o
    @trigger('change', 'opacity')

  getOpacity: ->
    @_opacity

  setPosition: ->
    super
    @trigger('change', 'position')


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
