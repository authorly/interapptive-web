class App.Views.ImageWidgetContextMenu extends Backbone.View
  POSITION_TIMER: null
  CONTROL_KEYS: _.map ['backspace', 'tab', 'enter', 'home', 'end', 'left', 'right'], (name) -> App.Lib.Keycodes[name]

  events: ->
    'click div':                                   'elementsClicked'

    'keydown  #x-coord, #y-coord':                 'enterKeyCoordListener'
    'keyup    #x-coord':                           'xCoordUpDownArrow'
    'keyup    #y-coord':                           'yCoordUpDownArrow'
    'keypress #x-coord, #y-coord':                 'numericInputListener'

    'keyup    #horizontal-scale, #vertical-scale': 'scaleAmountUpDownArrow'
    'keydown  #horizontal-scale, #vertical-scale': 'enterKeyScaleListener'
    'keypress #horizontal-scale, #vertical-scale': 'numericInputListener'

    'click .bring-to-front':                       'bringToFront'
    'click .put-in-back':                          'putInBack'


  initialize: ->
    @widget = @options.widget
    @_addListeners()


  render: ->
    # override


  remove: ->
    @_removeListeners()
    super


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
    event.preventDefault()
    event.stopPropagation()

    delta = switch event.keyCode
      when App.Lib.Keycodes.up   then 1
      when App.Lib.Keycodes.down then -1

    if delta?
      @_setScale
        direction: $(event.currentTarget).data('direction')
        delta:     delta


  numericInputListener: ->
    number = App.Lib.Keycodes[0] <= event.which <= App.Lib.Keycodes[9]
    ok = not event.which or number or @CONTROL_KEYS.indexOf(event.which) > -1

    switch event.target.id
      when 'x-coord', 'y-coord'
        ok = true if event.which == App.Lib.Keycodes.minus

    event.preventDefault() unless ok


  enterKeyCoordListener: (event) ->
    if event.keyCode is App.Lib.Keycodes.enter
      @_delayedSavePosition(@_position())


  enterKeyScaleListener: (event) ->
    if event.keyCode is App.Lib.Keycodes.enter
      @_setScale
        direction: $(event.currentTarget).data('direction')


  bringToFront: (e) ->
    e.stopPropagation()
    App.vent.trigger('bring_to_front:sprite', @widget)


  putInBack: (e) ->
    e.stopPropagation()
    App.vent.trigger('put_in_back:sprite', @widget)


  _addListeners: ->
    $('body').on('keyup', @_moveSpriteWithArrows)
    @widget.on('move', @_changeCoordinates, @)

    App.currentSelection.on 'change:keyframe', @_keyframeChanged, @


  _removeListeners: ->
    $('body').off('keyup', @_moveSpriteWithArrows)
    @widget.off('move', @_changeCoordinates, @)

    App.currentSelection.off 'change:keyframe', @_keyframeChanged, @


  _keyframeChanged: (keyframe) ->
    @render()


  _changeCoordinates: (new_point) ->
    return unless new_point?
    @$('#x-coord').val(parseInt(new_point.x))
    @$('#y-coord').val(parseInt(new_point.y))


  _moveSpriteWithArrows: (event) =>
    # Make sure we do not move the sprite in case both sprite and
    # coordinate inputs have focus. Instead just increment pixels
    # in coordinate inputs with _addUpDownArrowListeners().
    for id in ['x-coord', 'y-coord', 'horizontal-scale', 'vertical-scale']
      return if @$('#' + id).is(':focus')

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


  _setPosition: (point) ->
    @getObject().set
      position:
        x: parseInt(point.x)
        y: parseInt(point.y)


  _setScale: (options) ->
    object = @getObject()
    input = @$("##{options.direction}-scale")
    scale = object.get('scale')[options.direction]
    target = if options.delta?
      scale + options.delta
    else
      parseInt(input.val())

    if target < 10
      @_scaleCantBeSet()
      input.val(scale)
    else
      input.val(target)

      newScale = _.extend {}, object.get('scale')
      newScale[options.direction] = target
      object.set scale: newScale


  _delayedSavePosition: (point) ->
    window.clearTimeout(@POSITION_TIMER)
    @POSITION_TIMER = window.setTimeout((=> @_setPosition(point)), 400)


  _scaleCantBeSet: ->
    App.vent.trigger('show:message', 'warning', 'Scale can not be set to less than 10.')
