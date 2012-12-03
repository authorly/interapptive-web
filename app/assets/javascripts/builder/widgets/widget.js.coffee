##
# A `Widget` is an entity that has a graphical representation and that
# responds to user interactions.
#
# # dira, 2012-12-03 it would be better if widgets were independent of
# the concept of storybook.
# It also belongs to a storybook.
#
#
# Graphical properties:
# _opacity
# _highlighted
# _mouse_over
# draggable
#
class App.Builder.Widgets.Widget extends cc.Node

  draggable: true


  _mouse_over: false


  @idGenerator = new App.Lib.Counter


  constructor: (options={}) ->
    super
    _.extend(this, Backbone.Events)

    @_opacity = 255
    @_highlighted = false

    if options.id
      @id = App.Builder.Widgets.Widget.idGenerator.check(options.id)
    else
      @id = App.Builder.Widgets.Widget.idGenerator.next()

    if options.position
      @setPosition(new cc.Point(options.position.x, options.position.y))

    @on 'mouseover', @mouseOver
    @on 'mouseout',  @mouseOut
    @on 'mousemove', @mouseMove
    @on 'dblclick',  @doubleClick



  mouseOver: ->
    @_mouse_over = true


  mouseOut: ->
    @_mouse_over = false


  mouseMove: ->


  doubleClick: ->


  isHighlighted: ->
    return @_highlighted


  highlight: ->
    return if @isHighlighted()

    @_highlighted = true
    App.Builder.Widgets.WidgetDispatcher.trigger('widget:highlight', @id)


  unHighlight: ->
    return unless @isHighlighted()

    @_highlighted = false
    App.Builder.Widgets.WidgetDispatcher.trigger('widget:unhighlight', @id)


  setOpacity: (opacity) ->
    @_opacity = opacity


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
      s.width  * scale
      s.height * scale
    )


  toHash: ->
    id: @id
    type: Object.getPrototypeOf(this).constructor.name
    position:
      x: parseInt(@getPosition().x)
      y: parseInt(@getPosition().y)



  pointToLocal: (point) ->
    return unless @parent?

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
    # @removeFromStorybook(@_storybook) if @_storybook
    @_storybook = storybook
    # @addToStorybook(storybook) if storybook


  # removeFromStorybook: (storybook) =>


  # addToStorybook: (storybook) =>

