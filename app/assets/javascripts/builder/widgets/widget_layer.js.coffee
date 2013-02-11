# Displays the widgets on the main canvas, and handles user interaction (mouse
# and touch events).
# @_capturedWidget the widget on which mouse down was triggered (before other UI events)
class App.Builder.Widgets.WidgetLayer extends cc.Layer

  DEFAULT_CURSOR = 'default'

  CANVAS_ID = 'builder-canvas'

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
    @addClickOutsideCanvasEventListener()
    @addCanvasMouseLeaveListener()

    @widgets.on 'add',    @addWidget,    @
    @widgets.on 'remove', @removeWidget, @
    @widgets.on 'change:position change:scale', @updateWidget, @
    @widgets.on 'change:z_order', @reorderWidget, @

    App.currentSelection.on 'change:widget', @widgetSelected, @


  addWidget: (widget) ->
    if widget.get('type') == 'SpriteOrientation'
      @updateFromOrientation(widget)
    else
      # console.log 'add', widget
      view = new App.Builder.Widgets[widget.get('type')](model: widget)
      @addChild(view)
      @views.push view
      @updateKeyframePreview()


  removeWidget: (widget) ->
    return if widget.get('type') == 'SpriteOrientation'
    # console.log 'remove', widget

    view = @_getView(widget)
    @removeChild(view)
    @views.splice(@views.indexOf(view), 1)
    @updateKeyframePreview()


  updateWidget: (widget) ->
    if widget.get('type') == 'SpriteOrientation'
      # `SpriteWidget`s are modified indirectly, by changing their
      # current orientation. So we deal separately with changes in
      # orientations
      @updateFromOrientation(widget)


  reorderWidget: (widget) ->
    view = @_getView(widget)
    # Hack - remove & add again the widget, so the layer takes the new zOrder
    # into account. Tried to use `reorderChild` but it did not work (the best
    # result I got was having it not show all the widgets with a smaller zOrder).
    # @dira 2013-02-11
    @removeChild view
    @addChild view


  updateFromOrientation: (orientation) ->
    sprite = orientation.spriteWidget()
    # console.log 'update from orientation', orientation, sprite, @_getView(sprite)
    @_getView(sprite).applyOrientation(orientation)
    @updateKeyframePreview()


  _getView: (widget) ->
    view = _.find @views, (view) -> view.model == widget


  updateKeyframePreview: ->
    window.setTimeout @_updateKeyframePreview, 100


  _updateKeyframePreview: =>
    canvas = document.getElementById @CANVAS_ID
    image = Canvas2Image.saveAsPNG canvas, true, 110, 83

    @widgets.currentKeyframe?.setPreviewDataUrl image.src




  # clearScene: =>
    # @clearWidgets()
    # @removeAllChildrenWithCleanup()


  # clearWidgets: (conditionallyRemove = ((w) -> true)) ->
    # widgetsToRemove = _.filter(@widgets, conditionallyRemove)
    # @widgets = _.difference(@widgets, widgetsToRemove)
    # _.map(widgetsToRemove, (widget) =>
      # @removeChild(widget) if widget.type != "TextWidget"
      # delete widget.parent
    # )




  addWidget: (widget) ->
    return if widget instanceof App.Models.SpriteOrientation

    view = new App.Builder.Widgets[widget.get('type')](model: widget)
    @addChild(view)
    view.parent = this
    @views.push(view)


  removeWidget: (widget) ->
    return if widget instanceof App.Models.SpriteOrientation

    _.each @views, (view, index) =>
      if view.model is widget
        @removeChild(view)
        @views.splice(index, 1)


  widgetAtPoint: (point) ->
    widgets = []
    for widget,i in @views
      if widget.getIsVisible() and widget.isPointInside(point)
        widgets.push widget

    _.max widgets, (widget) -> widget.model.get('z_order')


  ccTouchesBegan: (touches) ->
    touch = touches[0]
    point = @_getTouchCoordinates(touch)
    widget = @widgetAtPoint(point)
    return unless widget

    widget.mouseDown
      touch: touch
      canvasPoint: point

    @_capturedWidget = widget
    @_previousPoint = new cc.Point(point.x, point.y)


  ccTouchesMoved: (touches) ->
    touch = touches[0]
    point = @_getTouchCoordinates(touch)

    @moveCapturedWidget(point) if @_capturedWidget?
    @mouseOverWidgetAtTouch(touch, @_capturedWidget)


  ccTouchesEnded: (touches) ->
    touch = touches[0]
    point = @_getTouchCoordinates(touch)

    if @_capturedWidget
      @_capturedWidget.mouseUp
        touch: touch
        canvasPoint: point

    delete @_previousPoint
    delete @_capturedWidget


  moveCapturedWidget: (point) ->
    newPoint = new cc.Point(parseInt(point.x), parseInt(point.y))
    @_previousPoint ||= newPoint

    delta = cc.ccpSub(point, @_previousPoint)
    newPosition = cc.ccpAdd(delta, @_capturedWidget.getPosition())

    @_capturedWidget.draggedTo(newPosition)
    @_previousPoint = newPoint


  mouseOverWidgetAtTouch: (touch, widget=null) ->
    point = @_getTouchCoordinates(touch)
    widget ||= @widgetAtPoint(point)

    if widget
      widget.mouseMove
        touch:       touch
        canvasPoint: point

    if widget isnt @_mouseOverWidget
      @_mouseOverWidget?.mouseOut
        touch:       touch
        canvasPoint: point
        newWidget:   widget

      widget?.mouseOver
        touch:          touch
        canvasPoint:    point
        previousWidget: @_mouseOverWidget

      @_mouseOverWidget = widget


  widgetSelected: (__, widget) ->
    @_deselectSpriteWidgets()

    widget = @_getView(widget)
    @_selectedWidget = widget
    widget?.select()

  ##
  # RFCTR - Used by the sprite form palette
  #         Not sure if we'll need to keep it though.
  #                                         C.W. 2/2/2013
  #
  #   hasCapturedWidget: ->
  #     true if @_capturedWidget
  #

  _deselectSpriteWidgets: =>
    widget.deselect() for widget in @views when widget.isSpriteWidget()


  addCanvasMouseLeaveListener: ->
    $('#' + @CANVAS_ID).bind 'mouseout', (event) =>
      @setCursor 'default'


  setCursor: (name) ->
    cursor = switch name
      when 'resize'
        'se-resize'
      when 'move'
        'move'
      when 'default'
        'default'
    document.body.style.cursor = cursor


  addClickOutsideCanvasEventListener: =>
    $('body').click (event) =>
      unless $(event.target).closest('#' + @CANVAS_ID).length
        App.currentSelection.set widget: null

    # # # Checks for a click outside the widget
    # cc.canvas.addEventListener 'click', (event) =>
      # el = cc.canvas
      # pos = {left:0, top:0, height:el.height}

      # ##
      # # RFCTR - DRY up
      # #       - Convert to function that returns touch object
      # #

      # while el != null
        # pos.left += el.offsetLeft
        # pos.top += el.offsetTop
        # el = el.offsetParent

      # tx = event.pageX
      # ty = event.pageY

      # mouseX = (tx - pos.left) / cc.Director.sharedDirector().getContentScaleFactor()
      # mouseY = (pos.height - (ty - pos.top)) / cc.Director.sharedDirector().getContentScaleFactor()

      # touch = new cc.Touch(0, mouseX, mouseY)
      # touch._setPrevPoint(cc.TouchDispatcher.preTouchPoint.x, cc.TouchDispatcher.preTouchPoint.y)
      # cc.TouchDispatcher.preTouchPoint.x = mouseX
      # cc.TouchDispatcher.preTouchPoint.y = mouseY

      # #
      # # END DRY
      # ##

      # return unless @_selectedWidget

      # point = @_getTouchCoordinates(touch)
      # widget = @widgetAtPoint(point)
      # if @_selectedWidget != widget
        # App.currentSelection.set widget: null


  # RFCTR - Dry up duplicate code w/ above
  addDblClickEventListener: ->
    ## FIXME Need a cleaner way to check for doubleclicks
    cc.canvas.addEventListener 'dblclick', (event) =>
      touch = @_calculateTouchFrom(event)
      point = @_getTouchCoordinates(touch)

      widget = @widgetAtPoint(point)
      if widget?
        widget.doubleClick touch: touch, point: point
        App.currentSelection.set widget: widget.model


  _getTouchCoordinates: (touch) ->
    point = touch.locationInView()
    # compensate the pointer's dimensions
    point.x -= 18
    point.y += 14
    point


  _calculateTouchFrom: (event) ->
    el = cc.canvas
    pos =
      height: el.height
      top:    0
      left:   0

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

    touch
