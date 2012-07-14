NEXT_WIDGET_ID = 1

class App.Builder.Widgets.Widget extends cc.Node

  draggable: true

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

    if options.id
      @id = options.id
    else
      @id = NEXT_WIDGET_ID
      NEXT_WIDGET_ID += 1

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

  pointToLocal: (point) ->
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
