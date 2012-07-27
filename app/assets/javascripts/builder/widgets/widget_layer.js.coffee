class App.Builder.Widgets.WidgetLayer extends cc.Layer

  constructor: ->
    super
    @widgets = []
    @_capturedWidget = null
    @_selectedWidget = null

    @setIsTouchEnabled(true)

    # FIXME Need a cleaner way to check for doubleclicks
    cc.canvas.addEventListener('dblclick', (event) =>
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
      widget.trigger('dblclick', touch, event)
    )
    
  clearWidgets: ->
    for widget in @widgets
      @removeChild(widget)

    # Clear array
    @widgets.splice(0)

  addWidget: (widget) ->
    @widgets.push(widget)
    @addChild(widget) unless widget instanceof App.Views.TextWidget

    App.storybookJSON.addWidget(App.currentKeyframe(), widget)

    this

  widgetAtTouch: (touch) ->
    @widgetAtPoint(touch.locationInView())

  widgetAtPoint: (point) ->
    for widget in @widgets
      continue if widget instanceof App.Views.TextWidget
      if widget.getIsVisible()
        local = widget.convertToNodeSpace(point)

        r = widget.rect()
        r.origin = new cc.Point(0, 0)

        # Fix bug in cocos2d-html5; It doesn't convert to local space correctly
        local.x += @getAnchorPoint().x * r.size.width
        local.y += @getAnchorPoint().y * r.size.height

        if cc.Rect.CCRectContainsPoint(r, local)
          return widget

    null

  ccTouchesBegan: (touches) ->
    widget = @widgetAtTouch(touches[0])
    return unless widget

    widget.trigger('mousedown')

    touch = touches[0].locationInView()

    @_capturedWidget = widget
    @_previousPoint = new cc.Point(touch.x, touch.y)

    return true

  ccTouchesMoved: (touches) ->
    point = touches[0].locationInView()
    @mouseOverWidgetAtPoint(point)

    if @_capturedWidget
      @moveCapturedWidget(point)

      App.builder.canDragBackground = false

  ccTouchesEnded: (touches) ->
    # TODO trigger('click')
    # Causes a save
    @_capturedWidget.trigger('change', 'position') if @_capturedWidget
    @_capturedWidget.trigger('mouseup') if @_capturedWidget

    delete @_previousPoint
    delete @_capturedWidget

    if App.builder.canDragBackground is false then App.builder.canDragBackground = true

  moveCapturedWidget: (point) ->
    @_previousPoint ||= point
    delta = cc.ccpSub(point, @_previousPoint)
    newPos = cc.ccpAdd(delta, @_capturedWidget.getPosition())

    @_capturedWidget.setPosition(newPos, false)
    @_previousPoint = new cc.Point(point.x, point.y)

  mouseOverWidgetAtPoint: (point) ->
    widget = @widgetAtPoint(point)

    if widget isnt @_mouseOverWidget
      @_mouseOverWidget.trigger('mouseout') if @_mouseOverWidget
      widget.trigger('mouseover') if widget
      @_mouseOverWidget = widget
