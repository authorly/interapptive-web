
##
# A `Widget` is an entity that has a graphical representation and that
# responds to user interactions.
#
# Graphical properties:
# _opacity
# _highlighted
# _mouse_over
# draggable
#
class App.Builder.Widgets.Widget extends cc.Node

  # draggable: true

  # _mouse_over: false


  constructor: (options) ->
    super

    @model = options.model
    _.extend(this, Backbone.Events)

    @_opacity = 255
    @_highlighted = false

    position = @model.get('position')
    @setPosition new cc.Point(position.x, position.y)

    # @on 'mouseover', @mouseOver
    # @on 'mouseout',  @mouseOut
    # @on 'mousemove', @mouseMove
    # @on 'dblclick',  @doubleClick

    # App.vent.on 'widget:change_zorder', @changeZOrder


  # changeZOrder: (z) ->
    # @setZOrder(z)
    # @trigger 'change', 'zOrder'


  # mouseOver: ->
    # @_mouse_over = true


  # mouseOut: ->
    # @_mouse_over = false


  # mouseMove: ->


  doubleClick: ->
    # noop


  # isHighlighted: ->
    # return @_highlighted


  # highlight: ->
    # return if @isHighlighted()
    # @_highlighted = true
    # App.Builder.Widgets.WidgetDispatcher.trigger('widget:highlight', @id)


  # unHighlight: ->
    # return unless @isHighlighted()
    # @_highlighted = false
    # App.Builder.Widgets.WidgetDispatcher.trigger('widget:unhighlight', @id)


  # setOpacity: (opacity) ->
    # @_opacity = opacity


  # getOpacity: ->
    # @_opacity


  # setZOrder: (z, triggerEvent=true) ->
    # @_zOrder = z


  # getZOrder: ->
    # @_zOrder


  # setPosition: (pos, triggerEvent=true)->
    # super
    # @trigger('change', 'position') if triggerEvent


  # rect: ->
    # p = @getPosition()
    # s = @getContentSize()
    # a = @getAnchorPoint()
    # scale = @getScale()

    # cc.RectMake(
      # p.x - s.width  * a.x
      # p.y - s.height * a.y
      # s.width  * scale
      # s.height * scale
    # )


  # toHash: ->
    # hash                      = {}
    # hash.id                   = @id
    # hash.type                 = Object.getPrototypeOf(this).constructor.name
    # hash.position             =
      # x: @getPosition().x
      # y: @getPosition().y
    # hash.retention            = @retention
    # hash.retentionMutability  = @retentionMutability

    # hash


  # toSceneHash: ->
    # @toHash()


  # pointToLocal: (point) ->
    # return unless @parent?

    # local = @convertToNodeSpace(point)

    # r = @rect()
    # r.origin = new cc.Point(0, 0)

    # # Fix bug in cocos2d-html5; It doesn't convert to local space correctly
    # local.x += @parent.getAnchorPoint().x * r.size.width* 0.59
    # local.y += @parent.getAnchorPoint().y * r.size.height* 0.59

    # local


  # isPointInside: (point) ->
    # local = @pointToLocal(point)

    # r = @rect()
    # r.origin = new cc.Point(0, 0)

    # return cc.Rect.CCRectContainsPoint(r, local)


  # setStorybook: (storybook) ->
    # # @removeFromStorybook(@_storybook) if @_storybook
    # @_storybook = storybook
    # # @addToStorybook(storybook) if storybook


  # # removeFromStorybookJSON: (storybook) =>


  # # addToStorybookJSON: (storybook) =>


  # isSpriteWidget: ->
    # @ instanceof App.Builder.Widgets.SpriteWidget


  # isTouchWidget: ->
    # @ instanceof App.Builder.Widgets.TouchWidget


  # save: ->
    # throw new Error("Must be implemented in the subclass")
