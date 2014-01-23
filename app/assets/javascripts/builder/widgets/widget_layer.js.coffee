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

    @canvas = $('#' + CANVAS_ID)
    # For overflow layer, reposition widget layer
    horizontalPanelHeight = (@canvas.attr('height') - App.Config.dimensions.height) / 2
    verticalPanelWidth = (@canvas.attr('width') - App.Config.dimensions.width) / 2
    @position = new cc.Point(verticalPanelWidth, horizontalPanelHeight)
    @setPosition @position

    @canvasScale = @canvas.height() / @canvas.attr('height')

    $('body').on  'keydown', @_arrowPressed

    # Collection (array) of Backbone models
    @widgets = widgetsCollection

    # Array of Cocos2d objects ("widgets")
    @views = []

    @_capturedWidget = null
    @_selectedWidget = null

    @setKeyboardEnabled(true)
    @setMouseEnabled(false)
    @setTouchEnabled(false)
    # see comment @onMouseMoved
    # @dira 2014-02-03
    @canvas.on 'mousemove', @onMouseMoved
    @canvas.on 'mousedown', @onTouchesBegan
    @canvas.on 'mouseup', @onTouchesEnded

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

    background = cc.LayerColor.create(new cc.Color4B(255, 255, 255, 255),
      App.Config.dimensions.width, App.Config.dimensions.height)
    @addChild background

    @widgets.each @addWidget


  addWidget: (widget) =>
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
      if widget.isVisible() and widget.isPointInside(point)
        widgets.push widget

    return null if widgets.length == 0
    _.max widgets, (widget) -> widget.model.get('z_order')


  # The scrollable and context menu plugins 'steal' away
  # the focus from the canvas. Couldn't figure out how to make it work,
  # using jquery for all mouse events instead. @dira 2014-02-03
  onMouseMoved: (event) =>
    _point = @_calculateTouchPointFrom(event)
    point = @_getLocalPoint(_point)

    widget = @widgetAtPoint(point)

    if widget
      widget.mouseMove
        canvasPoint: point

    if widget isnt @_mouseOverWidget
      @_mouseOverWidget?.mouseOut
        canvasPoint: point
        newWidget:   widget

      widget?.mouseOver
        canvasPoint:    point
        previousWidget: @_mouseOverWidget

      @_mouseOverWidget = widget

    @moveCapturedWidget(point) if @_capturedWidget?


  onTouchesBegan: (event) =>
    _point = @_calculateTouchPointFrom(event)
    point = @_getLocalPoint(_point)
    widget = @widgetAtPoint(point)
    return unless widget

    widget.mouseDown
      canvasPoint: point

    @_capturedWidget = widget
    @_previousPoint = new cc.Point(point.x, point.y)
    @_startPoint = @_previousPoint


  onTouchesEnded: (event) =>
    _point = @_calculateTouchPointFrom(event)
    point = @_getLocalPoint(_point)

    if @_capturedWidget?
      if @_samePoint(@_startPoint, point)
        # click
        widget = @widgetAtPoint(point)
        App.currentSelection.set widget: widget?.model
      else
        # drag
        @_capturedWidget.mouseUp
          canvasPoint: point
    else
      App.currentSelection.set widget: null

    delete @_startPoint
    delete @_previousPoint
    delete @_capturedWidget


  moveCapturedWidget: (point) ->
    @_previousPoint ||= point

    @_capturedWidget.dragged(@_previousPoint, point)

    @_previousPoint = point


  onKeyDown: (event) =>
    return unless @_selectedWidget?
    return unless event.target == document.body

    event.preventDefault()

    delta = 10
    dx = 0; dy = 0
    switch event.keyCode
      when App.Lib.KeyCodes.left  then dx = -delta
      when App.Lib.KeyCodes.up    then dy =  delta
      when App.Lib.KeyCodes.right then dx =  delta
      when App.Lib.KeyCodes.down  then dy = -delta
      else return

    model = if @_selectedWidget.getModelForPositioning? then @_selectedWidget.getModelForPositioning() else @_selectedWidget.model
    position = model.get('position')
    model.set
      position:
        x: position.x + dx
        y: position.y + dy

  onKeyUp: ->


  _samePoint: (p1, p2) ->
    eps = 0.1
    Math.abs(p1.x - p2.x) < eps and Math.abs(p1.y - p2.y) < eps


  widgetSelected: (__, widget) ->
    @_selectedWidget = @_getView(widget)
    for view in @views
      view.deselect() unless view == @_selectedWidget

    @_selectedWidget?.select()


  _viewDeselected: (view) ->
    if @_selectedWidget == view
      @_selectedWidget = null
      App.currentSelection.set widget: null


  addCanvasMouseLeaveListener: ->
    @canvas.on 'mouseout', (event) =>
      @setCursor 'default'


  setCursor: (name) ->
    cursor = switch name
      when 'resize'
        'se-resize'
      when 'move'
        'move'
      when 'default'
        'default'
    @canvas[0].style.cursor = cursor


  addClickOutsideCanvasEventListener: =>
    $('body').click (event) =>
      target = $(event.target)
      inCanvas = target.id == CANVAS_ID or target.closest('#' + CANVAS_ID).length > 0

      # the context menu should stop propagation on clicking on its elements
      # but it doesn't
      inContextMenu = target.closest('.context-menu-list').length > 0

      onEditableElement = target.attr('contentEditable') || target.closest('[contentEditable=true]').length > 0

      onSidebar = target.closest('.sidebar').length > 0

      onKeyframeList = target.closest('#keyframe-list').length > 0

      unless inCanvas or inContextMenu or onEditableElement or onSidebar or onKeyframeList
        App.currentSelection.set widget: null


  addContextMenuEventListener: ->
    @canvas.on 'contextmenu', (event) =>
      _point = @_calculateTouchPointFrom(event)
      point = @_getLocalPoint(_point)

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

      @_capturedWidget = widget
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
          name:     'As in previous scene frame'
          disabled:  ->
            !App.currentSelection.get('keyframe').previous()?
          callback: @asInPreviousKeyframe

        as_next:
          name:     'As in next scene frame'
          disabled:  ->
            !App.currentSelection.get('keyframe').next()?
          callback: @asInNextKeyframe

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
    App.trackUserAction('Restored default main menu button', source: "right click menu")
    model = @_capturedWidget.model
    model.useDefaultImage()


  removeSpriteWithContextMenu: =>
    App.trackUserAction 'Removed widget',
      type: @_capturedWidget.constructor.name
      source: 'right click menu'
    @_capturedWidget.model.collection.remove(@_capturedWidget.model)
    @_capturedWidget = null


  editSpriteWithContextMenu: =>
    App.currentSelection.set widget: @_capturedWidget.model
    @_capturedWidget = null


  scaleSpriteWidgetFromModel: (modelAndScaleData) ->
    widgetModel = modelAndScaleData.model
    scale = modelAndScaleData.scale

    view = @_getView(widgetModel)
    view.setScale(scale)


  asInPreviousKeyframe: =>
    keyframe = App.currentSelection.get('keyframe')
    @_capturedWidget.model.asPreviousKeyframe keyframe


  asInNextKeyframe: =>
    keyframe = App.currentSelection.get('keyframe')
    @_capturedWidget.model.asNextKeyframe keyframe


  _getLocalPoint: (point) ->
    new cc.Point(
      point.x/@canvasScale - @position.x,
      point.y/@canvasScale - @position.y
    )


  # Get cocos2s point coordinates from a jquery event.
  _calculateTouchPointFrom: (event) =>
    pos = @canvas.offset()
    pos.height = @canvas[0].height

    tx = event.pageX
    ty = event.pageY

    mouseX = tx - pos.left
    mouseY = pos.height - (ty - pos.top) - 1071

    new cc.Point(mouseX, mouseY)
