# Displays the widgets on the main canvas, and handles user interaction (mouse
# and touch events).
#
# Properties:
#   @_capturedWidget - the widget on which mouse down was triggered (before other UI events)
#
# Methods:
#   _calculateTouchFrom(event)  - Calculates the touch point relative to the canvas
#
#   addClickOutsideCanvasEventListener - Listens for a click off of the selected sprite,
#                                        but only within the canvas
#
#
class App.Builder.Widgets.WidgetLayer extends cc.Layer

  DEFAULT_CURSOR = 'default'

  CANVAS_ID = 'builder-canvas'


  constructor: (widgetsCollection) ->
    super

    # For image overflow layer, reposition widget layer
    @setPosition new cc.Point(250, 400)

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

    @initializeContextMenus()
    @addContextMenuEventListener()

    @widgets.on 'add',    @addWidget,    @
    @widgets.on 'remove', @removeWidget, @
    @widgets.on 'change:position change:scale', @updateWidget, @
    @widgets.on 'change:z_order', @reorderWidget, @

    App.vent.on 'scale:sprite_widget', @scaleSpriteWidgetFromModel, @
    App.currentSelection.on 'change:widget', @widgetSelected, @


  addWidget: (widget) ->
    if widget instanceof App.Models.SpriteOrientation
      @updateFromOrientation(widget)
    else
      view = new App.Builder.Widgets[widget.get('type')](model: widget)
      view.parent = @
      @addChild(view)
      @views.push view


  removeWidget: (widget) ->
    return if widget instanceof App.Models.SpriteOrientation

    view = @_getView(widget)
    @removeChild(view)
    @views.splice(@views.indexOf(view), 1)


  updateWidget: (widget) ->
    if widget instanceof App.Models.SpriteOrientation
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


  _getView: (widget) ->
    view = _.find @views, (view) -> view.model == widget


  @updateKeyframePreview: (keyframe) ->
    canvas = document.getElementById CANVAS_ID
    image = Canvas2Image.saveAsPNG canvas, true, 235, 230

    keyframe.setPreviewDataUrl image.src


  widgetAtPoint: (point) ->
    widgets = []
    for widget,i in @views
      if widget.getIsVisible() and widget.isPointInside(point)
        widgets.push widget

    return null if widgets.length == 0
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
    @_capturedWidget.model.trigger('move', newPosition)
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
      # the context menu should stop propagation on clicking on its elements
      # but it doesn't
      if !$(event.target).closest('#' + @CANVAS_ID).length and
         !$(event.target).closest('.context-menu-list').length
        App.currentSelection.set widget: null


  addDblClickEventListener: ->
    cc.canvas.addEventListener 'dblclick', (event) =>
      touch = @_calculateTouchFrom(event)
      point = @_getTouchCoordinates(touch)

      widget = @widgetAtPoint(point)
      if widget?
        widget.doubleClick touch: touch, point: point
        App.currentSelection.set widget: widget.model


  addContextMenuEventListener: ->
    cc.canvas.addEventListener 'contextmenu', (event) =>
      touch = @_calculateTouchFrom(event)
      point = @_getTouchCoordinates(touch)

      widget = @widgetAtPoint(point)
      return unless widget?

      event.preventDefault()
      selector = ''
      if widget.isSpriteWidget()
        selector = '.sprite'
      else if widget.isTextWidget()
        selector = '.text'
      else
        return


      $el = $('#context-menu ' + selector)
      $el.contextMenu x: event.clientX, y: event.clientY

      $('header').on 'click.contextMenuHandler', -> $el.contextMenu('hide')

  hideContextMenuEventListener: =>
    $('header').off 'click.contextMenuHandler'
    @_capturedWidget = null


  initializeContextMenus: ->
    $.contextMenu
      selector: '#context-menu .sprite'

      zIndex: 100

      events:
        hide: @hideContextMenuEventListener

      items:
        edit_image:
          name:     'Edit Image...'
          icon:     'edit'
          callback: @editSpriteWithContextMenu

        remove_image:
          name:     'Remove Image'
          icon:     'delete'
          callback: @removeSpriteWithContextMenu

        seperator:  "---------",

        bring_to_front:
          name:     'Bring to Front'
          callback: @bringSpriteToFront

        put_in_back:
          name:     'Put in Back'
          callback: @putSpriteInBack

    $.contextMenu
      selector: '#context-menu .text'

      zIndex: 100

      events:
        hide: @hideContextMenuEventListener

      items:
        remove_text:
          name:     'Remove Text'
          icon:     'delete'
          callback: @removeSpriteWithContextMenu


  bringSpriteToFront: =>
    App.vent.trigger 'bring_to_front:sprite', @_capturedWidget.model
    @_capturedWidget = null


  putSpriteInBack: =>
    App.vent.trigger 'put_in_back:sprite', @_capturedWidget.model
    @_capturedWidget = null


  removeSpriteWithContextMenu: =>
    @_capturedWidget.model.collection.remove(@_capturedWidget.model)
    @_capturedWidget = null
    App.vent.trigger 'remove:widget'


  editSpriteWithContextMenu: =>
    App.currentSelection.set widget: @_capturedWidget.model
    @_capturedWidget = null


  scaleSpriteWidgetFromModel: (modelAndScaleData) ->
    widgetModel = modelAndScaleData.model
    scale = modelAndScaleData.scale

    view = @_getView(widgetModel)
    view.setScale(scale)


  _getTouchCoordinates: (touch) ->
    point = touch.locationInView()
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
