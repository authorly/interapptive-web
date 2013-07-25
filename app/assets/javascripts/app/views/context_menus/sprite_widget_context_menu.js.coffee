class App.Views.SpriteWidgetContextMenu extends Backbone.View
  POSITION_TIMER: null
  CONTROL_KEYS: _.map ['backspace', 'tab', 'enter', 'home', 'end', 'left', 'right'], (name) -> App.Lib.Keycodes[name]

  events:
    'click .bring-to-front': 'bringToFront'
    'click .put-in-back':    'putInBack'
    'click .remove':         'deleteSprite'

  template: JST["app/templates/context_menus/sprite_widget_context_menu"]


  initialize: ->
    @widget = @options.widget


  render: ->
    @$el.html(@template(filename: @widget.filename(), orientation: @getCurrentOrientation()))
    @_addListeners()
    @


  remove: ->
    @_removeMoveListener()
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


  _addListeners: ->
    @_addClickListener()
    @_addUpDownArrowListeners()
    @_addNumericInputListener()
    @_addEnterKeyInputListener()
    @_addMoveListener()


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


  _addClickListener: ->
    @$('li').find('label, input').click (event) ->
      event.stopPropagation()


  _addUpDownArrowListeners: ->
    @$('#x-coord').keyup (event) =>
      _kc = event.keyCode

      if _kc is App.Lib.Keycodes.up
        @_moveSprite('right', 1)

      if _kc is App.Lib.Keycodes.down
        @_moveSprite('left', 1)

    @$('#y-coord').keyup (event) =>
      _kc = event.keyCode

      if _kc is App.Lib.Keycodes.up
        @_moveSprite('up', 1)

      if _kc is App.Lib.Keycodes.down
        @_moveSprite('down', 1)

    @$('#scale-amount').keyup (event) =>
      _kc = event.keyCode

      if _kc is App.Lib.Keycodes.up
        @_changeScale(1)

      if _kc is App.Lib.Keycodes.down
        @_changeScale(-1)


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


  _changeScale: (scale_by) ->
    scale = @getCurrentOrientation().get('scale') * 100
    @$('#scale-amount').val(scale + scale_by)
    @_setScale()


  _point: (x, y) ->
     new cc.Point(x, y)


  _delayedSavePosition: (point) ->
    window.clearTimeout(@POSITION_TIMER)
    @POSITION_TIMER = window.setTimeout((=> @_setPosition(point)), 400)


  _setPosition: (point) ->
    @getCurrentOrientation().set(position: { x: parseInt(point.x), y: parseInt(point.y) })


  _addNumericInputListener: ->
    @$('#x-coord, #y-coord, #scale-amount').keypress (event) => # Numeric keyboard inputs only
      number = App.Lib.Keycodes[0] <= event.which <= App.Lib.Keycodes[9]
      ok = not event.which or number or @CONTROL_KEYS.indexOf(event.which) > -1

      switch event.currentTarget.id
        when 'x-coord', 'y-coord'
          ok = true if event.which == App.Lib.Keycodes.minus

      event.preventDefault() unless ok


  _addEnterKeyInputListener: ->
    @$('#x-coord, #y-coord').keydown (e) =>
      @_delayedSavePosition(@_position()) if e.keyCode is App.Lib.Keycodes.enter

    @$('#scale-amount').keydown (e) =>
      @_setScale() if e.keyCode is App.Lib.Keycodes.enter


  _position: ->
    @_point(@$('#x-coord').val(), @$('#y-coord').val())


  _setScale: =>
    @getCurrentOrientation().set(scale: @_currentScale() / 100)


  _currentScale: ->
    window.parseFloat(@$('#scale-amount').val())
