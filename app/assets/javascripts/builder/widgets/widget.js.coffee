class App.Builder.Widgets.Widget extends cc.Node
  constructor: (options={}) ->
    super
    _.extend(this, Backbone.Events)

    @_opacity = 255

  setOpacity: (o) ->
    @_opacity = o

  getOpacity: ->
    @_opacity

  setPosition: (pos, triggerEvent=true)->
    super
    @trigger('change', 'position') if triggerEvent


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

  toHash: ->
    { type: Object.getPrototypeOf(this).constructor.name
    , position: { x: @getPosition().x
                , y: @getPosition().y
                }
    }
