class App.Builder.Widgets.WidgetLayer extends cc.Layer

  constructor: ->
    super
    @widgets = []
    @_capturedWidget = null
    @_selectedWidget = null

    @setIsTouchEnabled(true)
    @isKeyboardEnabled = true

    cc.canvas.addEventListener 'keypress', (event) =>
      console.log event.keyCode

    @addDblClickEventListener()
    @addClickOutsideEventListener() # Clicks outside the widget

  clearWidgets: ->
    for widget in @widgets
      #HACK unless TextWidget until I figure out whether TextWidget will still be stored in Keyframe.widgets
      @removeChild(widget) unless widget.type == "TextWidget"
      delete widget.parent

    # Clear array
    @widgets.splice(0)


  removeWidget: (widget) ->
    for _widget, i in @widgets
      if widget.id is _widget.id
        @removeChild(_widget)
        delete(_widget.parent)
        @widgets.splice(i, 1)


  addWidget: (widget, forSortable = false) ->
    App.activeSpritesList.addSpriteToList(widget) unless forSortable

    @widgets.push(widget)
    @addChild(widget)

    widget.parent = this

    widget.setStorybook(App.storybookJSON)

    this


  widgetAtTouch: (touch) ->
    @widgetAtPoint(touch.locationInView())


  widgetAtPoint: (point) ->
    widgetWithHighestZ =  @widgetHighestZAtPoint(point)
    return widgetWithHighestZ if widgetWithHighestZ

    for widget,i in @widgets
      widget if widget.getIsVisible() and widget.isPointInside(point)

    null


  widgetHighestZAtPoint: (point) ->
    widgetWithHighestZ =
      _.max @widgets, (widget) =>
        if widget.getIsVisible() and widget.isPointInside(point)
          return widget.getZOrder() unless typeof widget.getZOrder isnt "function"

    widgetWithHighestZ || false


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

    @mouseOverWidgetAtTouch(touch, @_capturedWidget)


  ccTouchesEnded: (touches) ->
    touch = touches[0]
    point = touch.locationInView()
    # TODO trigger('click')
    # Causes a save
    if @_capturedWidget
      # On each touch end, export the main canvas and log it in the console
      canvas = document.getElementById "builder-canvas"
      image = Canvas2Image.saveAsPNG canvas, true, 112, 84
      # TODO put imageSrc as the src of an image in the proper keyframe view
      console.log image

      @_capturedWidget.trigger('change', 'position')
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

  setSelectedWidget: (widget) ->
    @_selectedWidget = widget


  clearSelectedWidget: ->
    @_selectedWidget = null


  getSelectedWidget: ->
    @_selectedWidget


  hasCapturedWidget: ->
    true if @_capturedWidget


  getWidgetById: (id) ->
    for _widget in @widgets
      return _widget if parseInt(id) is parseInt(_widget.id)


  deselectSpriteWidgets: ->
    for widget in App.builder.widgetLayer.widgets
      continue unless widget instanceof App.Builder.Widgets.SpriteWidget
      widget.hideBorder() and widget.disableDragging()


  addClickOutsideEventListener: ->
    # Checks for a click outside the widget
    cc.canvas.addEventListener('click', (event) =>
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

      if @_selectedWidget
        if not widget
          @_selectedWidget.trigger('clickOutside', touch, event)

        if widget
          if @_selectedWidget.id != widget.id
            @_selectedWidget.trigger('clickOutside', touch, event)
    )


  addDblClickEventListener: ->
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
