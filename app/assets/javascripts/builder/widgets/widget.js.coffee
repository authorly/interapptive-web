NEXT_WIDGET_ID = 1

class App.Builder.Widgets.Widget extends cc.Node

  draggable: true

  _mouse_over: false

  @newFromHash: (hash) ->

    widget = new this(hash)

    # TODO: Sprite should be created w/ this zOrder, move to SpriteWidget
    if hash.zOrder then widget._zOrder = hash.zOrder

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

    @on("mouseover", @mouseOver)
    @on("mouseout", @mouseOut)
    @on('dblclick', @doubleClick)

  mouseOver: ->
    @_mouse_over = true
    
  mouseOut: -> 
    @_mouse_over = false
    
  mouseMove: ->
    console.log "mouse move from Widget"
  
  doubleClick: -> 
    console.log "Widget double click"

  isHighlighted: ->
    return @_highlighted

  highlight: ->
    unless @isHighlighted()
      console.info "Widget #{@id} highlighted."
      @_highlighted = true
      App.Builder.Widgets.WidgetDispatcher.trigger('widget:highlight', @id)

  unHighlight: ->
    if @isHighlighted()
      @_highlighted = false
      App.Builder.Widgets.WidgetDispatcher.trigger('widget:unhighlight', @id)

  setOpacity: (o) ->
    @_opacity = o

  getOpacity: ->
    @_opacity

  setZOrder: (z, triggerEvent=true) ->
    @_zOrder = z

  getZOrder: ->
    @_zOrder

  setPosition: (pos, triggerEvent=true)->
    super
    @trigger('change', 'position') if triggerEvent

  rect: ->
    p = @getPosition()
    s = @getContentSize()
    a = @getAnchorPoint()
    scale = @getScale()

    cc.RectMake(
      p.x - s.width  * a.x
      p.y - s.height * a.y
      s.width*@getScale()
      s.height*@getScale()
    )

  toHash: ->
    { id: @id
    , type: Object.getPrototypeOf(this).constructor.name
    , position: { x: parseInt(@getPosition().x)
                , y: parseInt(@getPosition().y)
                }
    }

  pointToLocal: (point) ->
    return unless @parent

    local = @convertToNodeSpace(point)

    r = @rect()
    r.origin = new cc.Point(0, 0)

    # Fix bug in cocos2d-html5; It doesn't convert to local space correctly
    local.x += @parent.getAnchorPoint().x * r.size.width
    local.y += @parent.getAnchorPoint().y * r.size.height

    local

  isPointInside: (point) ->
    local = @pointToLocal(point)

    r = @rect()
    r.origin = new cc.Point(0, 0)

    return cc.Rect.CCRectContainsPoint(r, local)

  setStorybook: (storybook) ->
    @removeFromStorybook(@_storybook) if @_storybook
    @_storybook = storybook
    @addToStorybook(storybook) if storybook

  removeFromStorybook: (storybook) =>

  addToStorybook: (storybook) =>

