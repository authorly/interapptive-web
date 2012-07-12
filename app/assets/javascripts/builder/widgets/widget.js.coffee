NEXT_WIDGET_ID = 1

class App.Builder.Widgets.Widget extends cc.Node

  @newFromHash: (hash) ->
    widget = new this(id: hash.id)

    widget.setPosition(new cc.Point(hash.position.x, hash.position.y)) if hash.position

    if hash.id >= NEXT_WIDGET_ID
      NEXT_WIDGET_ID = hash.id + 1


    return widget

  constructor: (options={}) ->
    super
    _.extend(this, Backbone.Events)

    @_opacity = 255
    @_highlighted = false

    if options.id
      @id = options.id
    else
      @id = NEXT_WIDGET_ID
      NEXT_WIDGET_ID += 1
      
    @on("mousemove", @mouseMove)
    
  mouseMove: ->
    @highlight() unless @isHighlighted()
    console.log "mouse move from Widget"

  isHighlighted: ->
    return @_highlighted

  highlight: ->
    console.log "Widget highlight"
    @_highlighted = true

  unHighlight: ->
    @_highlighted = false

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
    { id: @id
    , type: Object.getPrototypeOf(this).constructor.name
    , position: { x: @getPosition().x
                , y: @getPosition().y
                }
    }
