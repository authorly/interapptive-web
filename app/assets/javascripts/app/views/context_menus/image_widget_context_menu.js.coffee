class App.Views.ImageWidgetContextMenu extends Backbone.View
  POSITION_TIMER: null
  CONTROL_KEYS: _.map ['backspace', 'tab', 'enter', 'home', 'end', 'left', 'right'], (name) -> App.Lib.Keycodes[name]

  events: ->
    'click div':                                  'elementsClicked'
    'keyup #x-coord':                             'xCoordUpDownArrow'
    'keyup #y-coord':                             'yCoordUpDownArrow'
    'keyup #scale-amount':                        'scaleAmountUpDownArrow'
    'keypress #x-coord, #y-coord, #scale-amount': 'numericInputListener'
    'keydown #x-coord, #y-coord':                 'enterKeyCoordListener'
    'keydown #scale-amount':                      'enterKeyScaleListener'
    'click .bring-to-front':                      'bringToFront'
    'click .put-in-back':                         'putInBack'


  initialize: ->
    @widget = @options.widget


  render: ->
    okay = @_render()
    return @ unless okay?
    @_addListeners()
    @


  remove: ->
    @_removeMoveListener()
    App.currentSelection.off 'change:keyframe', @_render, @
    super


  bringToFront: (e) ->
    e.stopPropagation()
    App.vent.trigger('bring_to_front:sprite', @widget)


  putInBack:(e) ->
    e.stopPropagation()
    App.vent.trigger('put_in_back:sprite', @widget)


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


  numericInputListener: ->
    number = App.Lib.Keycodes[0] <= event.which <= App.Lib.Keycodes[9]
    ok = not event.which or number or @CONTROL_KEYS.indexOf(event.which) > -1

    switch event.target.id
      when 'x-coord', 'y-coord'
        ok = true if event.which == App.Lib.Keycodes.minus

    event.preventDefault() unless ok


  enterKeyCoordListener: (event) ->
    @_delayedSavePosition(@_position()) if event.keyCode is App.Lib.Keycodes.enter


  enterKeyScaleListener: (event) ->
    @_setScale() if event.keyCode is App.Lib.Keycodes.enter


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


  _measurePoint: (direction, pixels, x_oord, y_oord) ->
    point = null

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

    point


  _point: (x, y) ->
    new cc.Point(x, y)


  _position: ->
    @_point(@$('#x-coord').val(), @$('#y-coord').val())


  _setObjectPosition: (object, point) ->
    object.set(position: { x: parseInt(point.x), y: parseInt(point.y) })


  _setObjectScale: (object, scale_by) ->
    scale = object.get('scale') * 100
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
    object.set(scale: @_currentScale() / 100)


  _delayedSavePosition: (point) ->
    window.clearTimeout(@POSITION_TIMER)
    @POSITION_TIMER = window.setTimeout((=> @_setPosition(point)), 400)


  _currentScale: ->
    window.parseFloat(@$('#scale-amount').val())


  _scaleCantBeSet: ->
    App.vent.trigger('show:message', 'warning', 'Scale can not be set to less than ten.')
