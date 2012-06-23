class App.Builder.Widgets.WidgetLayer extends cc.Layer

  constructor: ->
    super
    @widgets = []
    @_capturedWidget = null

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


  addWidget: (widget) ->
    @widgets.push(widget)
    @addChild(widget)

    this

  widgetAtTouch: (touch) ->
    @widgetAtPoint(touch.locationInView())

  widgetAtPoint: (point) ->
    for widget in @widgets
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

    touch = touches[0].locationInView()

    @_capturedWidget = widget
    @_previousPoint = new cc.Point(touch.x, touch.y)

    return true

  ccTouchesMoved: (touches) ->
    point = touches[0].locationInView()
    if @_capturedWidget
      @moveCapturedWidget(point)
    else
      @highlightWidgetAtPoint(point)

  moveCapturedWidget: (point) ->
    @_previousPoint ||= point
    delta = cc.ccpSub(point, @_previousPoint)
    newPos = cc.ccpAdd(delta, @_capturedWidget.getPosition())

    @_capturedWidget.setPosition(newPos)
    @_previousPoint = new cc.Point(point.x, point.y)

  highlightWidgetAtPoint: (point) ->
    @unhighlightAllWidgets()

    widget = @widgetAtPoint(point)
    return unless widget

    widget.setOpacity(225)

  unhighlightAllWidgets: ->
    for widget in @widgets
      widget.setOpacity(150)

  ccTouchesEnded: (touches) ->
    @_previousPoint = null
    @_capturedWidget = null

