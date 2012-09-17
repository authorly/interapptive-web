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
      if widget
        widget.trigger('dblclick', touch, event)
    )
    
  clearWidgets: ->
    for widget in @widgets
      #HACK unless TextWidget until I figure out whether TextWidget will still be stored in Keyframe.widgets
      @removeChild(widget) unless widget.type == "TextWidget"
      delete widget.parent

    # Clear array
    @widgets.splice(0)

  addWidget: (widget) ->
    @widgets.push(widget)
    @addChild(widget)
    widget.parent = this

    widget.setStorybook(App.storybookJSON)

    this

  widgetAtTouch: (touch) ->
    @widgetAtPoint(touch.locationInView())

  widgetAtPoint: (point) ->
    for widget in @widgets
      continue if widget instanceof App.Views.TextWidget

      if widget.getIsVisible() and widget.isPointInside(point)
        return widget

    null

  ccTouchesBegan: (touches) ->
    widget = @widgetAtTouch(touches[0])
    return unless widget
    point = touches[0].locationInView()

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

    if @_capturedWidget
      App.builder.canDragBackground = false

    @mouseOverWidgetAtTouch(touch, @_capturedWidget)

  ccTouchesEnded: (touches) ->
    touch = touches[0]
    point = touch.locationInView()
    # TODO trigger('click')
    # Causes a save
    if @_capturedWidget
      @_capturedWidget.trigger('change', 'position')
      @_capturedWidget.trigger('mouseup', {
        touch: touch,
        canvasPoint: point
      })

    delete @_previousPoint
    delete @_capturedWidget

    if App.builder.canDragBackground is false then App.builder.canDragBackground = true

  moveCapturedWidget: (point) ->
    @_previousPoint ||= point
    delta = cc.ccpSub(point, @_previousPoint)
    newPos = cc.ccpAdd(delta, @_capturedWidget.getPosition())

    @_capturedWidget.setPosition(newPos, false)
    @_previousPoint = new cc.Point(point.x, point.y)

  mouseOverWidgetAtTouch: (touch, widget=null) ->
    point = touch.locationInView()
    widget ||= @widgetAtPoint(point)

    if widget
      widget.trigger('mousemove', {
        touch: touch,
        canvasPoint: point
      })

    if widget isnt @_mouseOverWidget
      if @_mouseOverWidget
        @_mouseOverWidget.trigger('mouseout', {
          touch: touch,
          canvasPoint: point,
          newWidget: widget
        })
      if widget
        widget.trigger('mouseover', {
          touch: touch,
          canvasPoint: point,
          previousWidget: @_mouseOverWidget
        })
      @_mouseOverWidget = widget
