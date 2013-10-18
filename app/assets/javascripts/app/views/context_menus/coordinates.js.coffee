class App.Views.Coordinates extends Backbone.View
  CONTROL_KEYS: _.map ['backspace', 'tab', 'enter', 'home', 'end', 'left', 'right'], (name) -> App.Lib.Keycodes[name]

  template: JST["app/templates/context_menus/coordinates"]

  events: ->
    'keyup    #x-coord':           'xCoordUpDownArrow'
    'keyup    #y-coord':           'yCoordUpDownArrow'
    'keypress #x-coord, #y-coord': 'numericInputListener'
    'keydown  #x-coord, #y-coord': 'enterKeyCoordListener'


  initialize: ->
    @model.on  'move',            @_changeCoordinates, @
    @model.on  'change:position', @_positionChanged, @


  remove: ->
    @model.on  'move',            @_changeCoordinates, @
    @model.off 'change:position', @_positionChanged, @


  render: ->
    @$el.html @template(model: @model)


  xCoordUpDownArrow: (event) ->
    _kc = event.keyCode

    if _kc is App.Lib.Keycodes.up
      delta = 1
    else if _kc is App.Lib.Keycodes.down
      delta = -1
    else
      return

    position = @model.get('position')
    @model.set
      position:
        x: position.x + delta
        y: position.y


  yCoordUpDownArrow: (event) ->
    _kc = event.keyCode

    if _kc is App.Lib.Keycodes.up
      delta = 1
    else if _kc is App.Lib.Keycodes.down
      delta = -1
    else
      return

    position = @model.get('position')
    @model.set
      position:
        x: position.x
        y: position.y + delta


  enterKeyCoordListener: (event) ->
    if event.keyCode is App.Lib.Keycodes.enter
      @model.set
        position:
          # Math.round('49-2') is NaN - assign 0
          x: Math.round(@$('#x-coord').val()) || 0
          y: Math.round(@$('#y-coord').val()) || 0


  numericInputListener: (event) ->
    number = App.Lib.Keycodes[0] <= event.which <= App.Lib.Keycodes[9]
    ok = not event.which or number or @CONTROL_KEYS.indexOf(event.which) > -1 or
      event.which == App.Lib.Keycodes.minus

    event.preventDefault() unless ok


  _positionChanged: ->
    @_changeCoordinates @model.get('position')


  _changeCoordinates: (position) ->
    @$('#x-coord').val position.x
    @$('#y-coord').val position.y
