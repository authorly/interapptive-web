class App.Views.SpriteWidgetContextMenu extends Backbone.View
  POSITION_TIMER: null
  CONTROL_KEYS: _.map ['backspace', 'tab', 'enter', 'home', 'end', 'left', 'right'], (name) -> App.Lib.Keycodes[name]

  events:
    'click .bring-to-front':                      'bringToFront'
    'click .put-in-back':                         'putInBack'
    'click .remove':                              'deleteSprite'
    'click div':                                  'elementsClicked'
    'keyup #x-coord':                             'xCoordUpDownArrow'
    'keyup #y-coord':                             'yCoordUpDownArrow'
    'keyup #scale-amount':                        'scaleAmountUpDownArrow'
    'keypress #x-coord, #y-coord, #scale-amount': 'numericInputListener'
    'keydown #x-coord, #y-coord':                 'enterKeyCoordListener'
    'keydown #scale-amount':                      'enterKeyScaleListener'

  template: JST["app/templates/context_menus/sprite_widget_context_menu"]


  initialize: ->
    @widget = @options.widget


  render: ->
    @_render()
    @_addListeners()
    @


  _render: ->
    @$el.html(@template(filename: @widget.filename(), orientation: @getCurrentOrientation()))


  remove: ->
    @_removeMoveListener()
    App.currentSelection.off 'change:keyframe', @_render, @
    super


  getCurrentOrientation: ->
    @widget.getOrientationFor(App.currentSelection.get('keyframe'))


  bringToFront: (e) ->
    e.stopPropagation()
    App.vent.trigger('bring_to_front:sprite', @widget)


  putInBack:(e) ->
    e.stopPropagation()
    App.vent.trigger('put_in_back:sprite', @widget)


  deleteSprite: (e) ->
    e.stopPropagation()
    @widget.collection.remove(@widget) if @widget.collection


  numericInputListener: ->
    number = App.Lib.Keycodes[0] <= event.which <= App.Lib.Keycodes[9]
    ok = not event.which or number or @CONTROL_KEYS.indexOf(event.which) > -1

    switch event.currentTarget.id
      when 'x-coord', 'y-coord'
        ok = true if event.which == App.Lib.Keycodes.minus

    event.preventDefault() unless ok

  elementsClicked: (event) ->
    event.stopPropagation()


  xCoordUpDownArrow: (event) ->
    _kc = event.keyCode

    if _kc is App.Lib.Keycodes.up
      @_moveSprite('right', 1)

    if _kc is App.Lib.Keycodes.down
      @_moveSprite('left', 1)


  yCoordUpDownArrow: (event) ->
    _kc = event.keyCode

    if _kc is App.Lib.Keycodes.up
      @_moveSprite('up', 1)

    if _kc is App.Lib.Keycodes.down
      @_moveSprite('down', 1)


  scaleAmountUpDownArrow: (event) ->
    _kc = event.keyCode

    if _kc is App.Lib.Keycodes.up
      @_setScale(1)

    if _kc is App.Lib.Keycodes.down
      @_setScale(-1)


  enterKeyScaleListener: (event) ->
    @_setScale() if event.keyCode is App.Lib.Keycodes.enter


  enterKeyCoordListener: (event) ->
    @_delayedSavePosition(@_position()) if event.keyCode is App.Lib.Keycodes.enter


  _moveSprite: (direction, pixels) ->
    current_orientation = @getCurrentOrientation()
    x_oord = current_orientation.get('position').x
    y_oord = current_orientation.get('position').y
    point  = null

    switch direction
      when 'left'
        @$('#x-coord').val(parseInt(x_oord) - pixels)
        point = @_point(x_oord - pixels, y_oord)

      when 'up'
        @$('#y-coord').val(parseInt(y_oord) + pixels)
        point = @_point(x_oord, y_oord + pixels)

      when 'right'
        @$('#x-coord').val(parseInt(x_oord) + pixels)
        point = @_point(x_oord + pixels, y_oord)

      when 'down'
        @$('#y-coord').val(parseInt(y_oord) - pixels)
        point = @_point(x_oord, y_oord - pixels)

    @_delayedSavePosition(point) if point?


  _point: (x, y) ->
     new cc.Point(x, y)


  _delayedSavePosition: (point) ->
    window.clearTimeout(@POSITION_TIMER)
    @POSITION_TIMER = window.setTimeout((=> @_setPosition(point)), 400)


  _setPosition: (point) ->
    @getCurrentOrientation().set(position: { x: parseInt(point.x), y: parseInt(point.y) })


  _addListeners: ->
    @_addMoveListener()
    App.currentSelection.on 'change:keyframe', @_render, @


  _addMoveListener: ->
    $('body').on('keyup', @_moveSpriteWithArrows)
    @widget.on('move', @_changeCoordinates, @)


  _removeMoveListener: ->
    $('body').off('keyup', @_moveSpriteWithArrows)
    @widget.off('move', @_changeCoordinates, @)


  _changeCoordinates: (new_point) ->
    return unless new_point?
    @$('#x-coord').val(parseInt(new_point.x))
    @$('#y-coord').val(parseInt(new_point.y))


  _moveSpriteWithArrows: (event) =>
    # Make sure we do not move the sprite in case both sprite and
    # coordinate inputs have focus. Instead just increment pixels
    # in coordinate inputs with _addUpDownArrowListeners().
    return if @$('#x-coord').is(':focus') or @$('#y-coord').is(':focus') or @$('#scale-amount').is(':focus')

    switch event.keyCode
      when App.Lib.Keycodes.left  then @_moveSprite('left',  1)
      when App.Lib.Keycodes.up    then @_moveSprite('up',    1)
      when App.Lib.Keycodes.right then @_moveSprite('right', 1)
      when App.Lib.Keycodes.down  then @_moveSprite('down',  1)

  _position: ->
    @_point(@$('#x-coord').val(), @$('#y-coord').val())


  _setScale: (scale_by) =>
    scale = @getCurrentOrientation().get('scale') * 100
    if scale_by?
      if parseInt(scale) + scale_by < 10
        @_scaleCantBeSet()
        @$('#scale-amount').val(parseInt(scale))
        return
      else
        @$('#scale-amount').val(parseInt(scale) + scale_by)

    else
      if parseInt(@_currentScale()) < 10
        @_scaleCantBeSet()
        @$('#scale-amount').val(parseInt(scale))
        return
    @getCurrentOrientation().set(scale: @_currentScale() / 100)


  _currentScale: ->
    window.parseFloat(@$('#scale-amount').val())


  _scaleCantBeSet: ->
    App.vent.trigger('show:message', 'warning', 'Scale can not be set to less than ten.')
