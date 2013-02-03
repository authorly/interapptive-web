# Displays the widgets on the main canvas, and handles user interaction (mouse
# and touch events).
class App.Builder.Widgets.WidgetLayer extends cc.Layer

  DEFAULT_CURSOR = 'default'

  constructor: (widgetsCollection) ->
    super

    # Collection (array) of Backbone models
    @widgets = widgetsCollection

    # Array of Cocos2d objects ("widgets")
    @views = []

    @_capturedWidget = null
    @_selectedWidget = null

    @setIsTouchEnabled(true)
    @isKeyboardEnabled = true

    @addDblClickEventListener()
    @addClickOutsideEventListener()
    @addCanvasMouseLeaveListener()

    @widgets.on 'add',    @addWidget,    @
    @widgets.on 'remove', @removeWidget, @
    @widgets.on 'change:position change:scale', @updateWidget, @

    App.vent.on 'sprite_widget:select', @deselectSpriteWidgets


  addCanvasMouseLeaveListener: ->
    # RFCTR - ? Trigger method in Sprite Widget?
    $('#builder-canvas').bind 'mouseout', (event) ->
      document.body.style.cursor = 'default'

  addWidget: (widget) ->
    return if widget.get('type') is 'SpriteOrientation'

    view = new App.Builder.Widgets[widget.get('type')](model: widget)
    @addChild(view)
    view.parent = this
    @views.push(view)


  removeWidget: (widget) ->
    return if widget.get('type') is 'SpriteOrientation'

    _.each @views, (view, index) =>
      if view.model is widget
        @removeChild(view)
        @views.splice(index, 1)


  widgetAtTouch: (touch) ->
    @widgetAtPoint(touch.locationInView())


  widgetAtPoint: (point) ->
    #widgetWithHighestZ =  @widgetHighestZAtPoint(point)
    #return widgetWithHighestZ if widgetWithHighestZ

    for widget,i in @views
      if widget.getIsVisible() and widget.isPointInside(point)
        return widget

    return null
  #widgetAtPoint: (point) ->
  #  #widgetWithHighestZ =  @widgetHighestZAtPoint(point)
  #  #return widgetWithHighestZ if widgetWithHighestZ
  #
  #  return widget for widget,i in @views when widget.getIsVisible() and widget.isPointInside(point)
  #  return null

  #
  # RFCTR: Re-integrate this functionality, move to modal
  #
  # widgetHighestZAtPoint: (point) ->
  #   widgetWithHighestZ =
  #     _.max @views, (widget) =>
  #       if widget.getIsVisible() and widget.isPointInside(point)
  #         return widget.getZOrder() unless typeof widget.getZOrder isnt "function"
  #
  #   widgetWithHighestZ || false
  #

  ccTouchesBegan: (touches) ->
    widget = @widgetAtTouch(touches[0])
    return unless widget

    point = touches[0].locationInView()

    # RFCTR - Remove brackets, match syntax
    widget.trigger('mousedown', {
      touch: touches[0],
      canvasPoint: point
    })

    @_capturedWidget = widget
    @_previousPoint = new cc.Point(point.x, point.y)

    return true


  ccTouchesMoved: (touches) ->
    touch = touches[0]
    point = touch.locationInView()

    if @_capturedWidget and @_capturedWidget.draggable
      @moveCapturedWidget(point)

    @mouseOverWidgetAtTouch(touch, @_capturedWidget)


  ccTouchesEnded: (touches) ->
    touch = touches[0]
    point = touch.locationInView()

    if @_capturedWidget
      @_capturedWidget.trigger('mouseup', {
        touch: touch,
        canvasPoint: point
      })

    delete @_previousPoint
    delete @_capturedWidget


  moveCapturedWidget: (point) ->
    @_previousPoint ||= point

    delta = cc.ccpSub(point, @_previousPoint)
    newPos = cc.ccpAdd(delta, @_capturedWidget.getPosition())

    @_capturedWidget.setPosition(newPos, false)
    @_previousPoint = new cc.Point(parseInt(point.x), parseInt(point.y))


  # RFCTR - Eliminate some brackets!
  mouseOverWidgetAtTouch: (touch, widget=null) ->
    point = touch.locationInView()
    widget ||= @widgetAtPoint(point)

    if widget
      widget.trigger('mousemove', {
        touch:       touch,
        canvasPoint: point
      })

    if widget isnt @_mouseOverWidget
      if @_mouseOverWidget
        @_mouseOverWidget.trigger('mouseout', {
          touch:       touch,
          canvasPoint: point,
          newWidget:   widget
        })

      if widget
        widget.trigger('mouseover', {
          touch:          touch,
          canvasPoint:    point,
          previousWidget: @_mouseOverWidget
        })

      @_mouseOverWidget = widget


  setSelectedWidget: (widget) ->
    @_selectedWidget = widget

  ##
  # RFCTR - Used by the sprite form palette
  #         Not sure if we'll need to keep it though.
  #                                         C.W. 2/2/2013
  #
  #   hasCapturedWidget: ->
  #     true if @_capturedWidget
  #

  deselectSpriteWidgets: =>
    widget.deselect() for widget in @views when widget.isSpriteWidget()


  addClickOutsideEventListener: =>   # RFCTR - unnecessary
    # # Checks for a click outside the widget
    cc.canvas.addEventListener 'click', (event) =>
      el = cc.canvas
      pos = {left:0, top:0, height:el.height}

      ##
      # RFCTR - DRY up
      #       - Convert to function that returns touch object
      #

      while el != null
        pos.left += el.offsetLeft
        pos.top += el.offsetTop
        el = el.offsetParent

      tx = event.pageX
      ty = event.pageY

      mouseX = (tx - pos.left) / cc.Director.sharedDirector().getContentScaleFactor()
      mouseY = (pos.height - (ty - pos.top)) / cc.Director.sharedDirector().getContentScaleFactor()

      touch = new cc.Touch(0, mouseX, mouseY)
      touch._setPrevPoint(cc.TouchDispatcher.preTouchPoint.x, cc.TouchDispatcher.preTouchPoint.y)
      cc.TouchDispatcher.preTouchPoint.x = mouseX
      cc.TouchDispatcher.preTouchPoint.y = mouseY

      #
      # END DRY
      ##

      return unless @_selectedWidget

      widget = @widgetAtPoint(touch.locationInView())
      if widget and @_selectedWidget isnt widget or not widget
        @_selectedWidget.trigger 'deselect'


  # RFCTR - Dry up duplicate code w/ above
  addDblClickEventListener: ->
    ## FIXME Need a cleaner way to check for doubleclicks
    cc.canvas.addEventListener 'dblclick', (event) =>
      el = cc.canvas
      pos = {left:0, top:0, height:el.height}

      while el != null
        pos.left += el.offsetLeft
        pos.top += el.offsetTop
        el = el.offsetParent

      tx = event.pageX
      ty = event.pageY

      mouseX = (tx - pos.left) / cc.Director.sharedDirector().getContentScaleFactor()
      mouseY = (pos.height - (ty - pos.top)) / cc.Director.sharedDirector().getContentScaleFactor()

      touch = new cc.Touch(0, mouseX, mouseY)
      touch._setPrevPoint(cc.TouchDispatcher.preTouchPoint.x, cc.TouchDispatcher.preTouchPoint.y)
      cc.TouchDispatcher.preTouchPoint.x = mouseX
      cc.TouchDispatcher.preTouchPoint.y = mouseY

      widget = @widgetAtPoint(touch.locationInView())
      if widget
        widget.trigger('double_click', touch, event)
