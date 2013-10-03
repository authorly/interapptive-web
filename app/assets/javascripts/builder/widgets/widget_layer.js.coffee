# Displays the widgets on the main canvas, and handles user interaction (mouse
# and touch events).
#
#
# Properties:
#   @_capturedWidget - the widget on which mouse down was triggered (before other UI events)
#
#
class App.Builder.Widgets.WidgetLayer extends cc.Layer

  CANVAS_ID = 'builder'


  constructor: (widgetsCollection) ->
    super

    # For overflow layer, reposition widget layer
    horizontalPanelHeight = ($(cc.canvas).attr('height') - App.Config.dimensions.height) / 2
    verticalPanelWidth = ($(cc.canvas).attr('width') - App.Config.dimensions.width) / 2
    @setPosition new cc.Point(verticalPanelWidth, horizontalPanelHeight)

    # Collection (array) of Backbone models
    @widgets = widgetsCollection

    # Array of Cocos2d objects ("widgets")
    @views = []

    @_capturedWidget = null
    @_selectedWidget = null

    @setIsTouchEnabled(true)
    @isKeyboardEnabled = true

    @addClickOutsideCanvasEventListener()
    @addCanvasMouseLeaveListener()

    @initializeContextMenus()
    @addContextMenuEventListener()

    @widgets.on 'add',    @addWidget,    @
    @widgets.on 'remove', @removeWidget, @
    @widgets.on 'change:position change:scale', @updateWidget, @
    @widgets.on 'change:z_order', @reorderWidget, @

    App.currentSelection.on 'change:widget', @widgetSelected, @


  addWidget: (widget) ->
    if widget instanceof App.Models.SpriteOrientation
      @updateFromOrientation(widget)
    else
      view = new App.Builder.Widgets[widget.get('type')](model: widget)
      view.parent = @
      @addChild(view)
      @views.push view
      view.on 'deselect', @_viewDeselected, @


  removeWidget: (widget) ->
    return if widget instanceof App.Models.SpriteOrientation

    view = @_getView(widget)
    @removeChild(view)
    @views.splice(@views.indexOf(view), 1)
    view.off 'deselect', @_viewDeselected, @

    if App.currentSelection.get('widget') == widget
      App.currentSelection.set widget: null


  updateWidget: (widget) ->
    if widget instanceof App.Models.SpriteOrientation
      # `SpriteWidget`s are modified indirectly, by changing their
      # current orientation. So we deal separately with changes in
      # orientations
      sprite = widget.spriteWidget()
    else if widget instanceof App.Models.ButtonWidget
      sprite = widget
    else
      return

    @_getView(sprite).applyOrientation(widget)


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
    @_startPoint = @_previousPoint


  ccTouchesMoved: (touches) ->
    touch = touches[0]
    point = @_getTouchCoordinates(touch)

    @moveCapturedWidget(point) if @_capturedWidget?
    @mouseOverWidgetAtTouch(touch, @_capturedWidget)


  ccTouchesEnded: (touches) ->
    touch = touches[0]
    point = @_getTouchCoordinates(touch)

    if @_capturedWidget?
      if @_samePoint(@_startPoint, point)
        # click
        widget = @widgetAtPoint(point)
        App.currentSelection.set widget: widget?.model
      else
        # drag
        @_capturedWidget.mouseUp
          touch: touch
          canvasPoint: point
    else
      App.currentSelection.set widget: null

    delete @_startPoint
    delete @_previousPoint
    delete @_capturedWidget


  moveCapturedWidget: (point) ->
    newPoint = new cc.Point(parseInt(point.x), parseInt(point.y))
    @_previousPoint ||= newPoint

    delta = cc.ccpSub(point, @_previousPoint)
    newPosition = cc.ccpAdd(delta, @_capturedWidget.getPosition())

    if @_capturedWidget.draggedTo(newPosition)
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


  _samePoint: (p1, p2) ->
    eps = 0.1
    Math.abs(p1.x - p2.x) < eps and Math.abs(p1.y - p2.y) < eps


  widgetSelected: (__, widget) ->
    view.deselect() for view in @views

    view = @_getView(widget)
    @_selectedWidget = view
    view?.select()


  _viewDeselected: (view) ->
    if @_selectedWidget == view
      @_selectedWidget == null
      App.currentSelection.set widget: null


  addCanvasMouseLeaveListener: ->
    $('#' + CANVAS_ID).bind 'mouseout', (event) =>
      @setCursor 'default'


  setCursor: (name) ->
    cursor = switch name
      when 'resize'
        'se-resize'
      else
        name
    document.body.style.cursor = cursor


  addClickOutsideCanvasEventListener: =>
    $('body').click (event) =>
      target = $(event.target)
      inCanvas = target.id == CANVAS_ID or target.closest('#' + CANVAS_ID).length > 0

      # the context menu should stop propagation on clicking on its elements
      # but it doesn't
      inContextMenu = target.closest('.context-menu-list').length > 0

      unless inCanvas or inContextMenu
        App.currentSelection.set widget: null


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
      else if widget.isButtonWidget()
        selector = '.button'
      else if widget.isTextWidget()
        selector = '.text'
      else if widget.isHotspotWidget()
        selector = '.hotspot'
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
        as_previous:
          name:     'As in previous keyframe'
          disabled:  ->
            !App.currentSelection.get('keyframe').previous()?
          callback: @asInPreviousKeyframe

        seperator1:  "---------",

        remove_image:
          name:     'Remove Image'
          icon:     'delete'
          callback: @removeSpriteWithContextMenu

        seperator2:  "---------",

        bring_to_front:
          name:     'Bring to Front'
          callback: @bringSpriteToFront

        put_in_back:
          name:     'Put in Back'
          callback: @putSpriteInBack

    $.contextMenu
      selector: '#context-menu .button'

      zIndex: 100

      events:
        hide: @hideContextMenuEventListener

      items:
        enable_disable:
          name:     'Enable/Disable'
          callback: @changeButtonStateWithContextMenu
          disabled:  =>
            !@_capturedWidget.model.canBeDisabled()

        seperator:  "---------",

        restore_default:
          name:     'Use default image'
          callback: @restoreDefaultMainMenuButtonImage

        seperator2:  "---------",

        bring_to_front:
          name:     'Bring to Front'
          callback: @bringSpriteToFront
          disabled:  =>
            @_capturedWidget.model.isHomeButton()

        put_in_back:
          name:     'Put in Back'
          callback: @putSpriteInBack
          disabled:  =>
            @_capturedWidget.model.isHomeButton()


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

    $.contextMenu
      selector: '#context-menu .hotspot'

      zIndex: 100

      events:
        hide: @hideContextMenuEventListener

      items:
        edit_text:
          name:     'Edit Hotspot...'
          icon:     'edit'
          callback: @editSpriteWithContextMenu

        remove_text:
          name:     'Remove Hotspot'
          icon:     'delete'
          callback: @removeSpriteWithContextMenu


  bringSpriteToFront: =>
    App.vent.trigger 'bring_to_front:sprite', @_capturedWidget.model
    @_capturedWidget = null


  putSpriteInBack: =>
    App.vent.trigger 'put_in_back:sprite', @_capturedWidget.model
    @_capturedWidget = null


  changeButtonStateWithContextMenu: =>
    model = @_capturedWidget.model
    if model.disabled()
      model.enable()
    else
      model.disable()


  restoreDefaultMainMenuButtonImage: =>
    model = @_capturedWidget.model
    model.useDefaultImage()


  removeSpriteWithContextMenu: =>
    @_capturedWidget.model.collection.remove(@_capturedWidget.model)
    @_capturedWidget = null


  editSpriteWithContextMenu: =>
    App.currentSelection.set widget: @_capturedWidget.model
    @_capturedWidget = null


  asInPreviousKeyframe: =>
    keyframe = App.currentSelection.get('keyframe')
    @_capturedWidget.model.asPreviousKeyframe keyframe


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

