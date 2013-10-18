class App.Views.Coordinates extends Backbone.View

  template: JST["app/templates/context_menus/coordinates"]

  events: ->
    'keypress #x-coord, #y-coord': 'keyPressed'
    'keyup    #x-coord, #y-coord': 'keyUp'


  initialize: ->
    @model.on  'move',            @_changeCoordinates, @
    @model.on  'change:position', @_positionChanged, @


  remove: ->
    @model.on  'move',            @_changeCoordinates, @
    @model.off 'change:position', @_positionChanged, @


  render: ->
    @$el.html @template(model: @model)


  keyUp: (event) ->
    @_removeInnerMinus event
    @_moveByKeys       event
    @_setPosition      event


  _removeInnerMinus: (event) ->
    return unless event.keyCode in App.Lib.KeyCodes.minus

    element = @$(event.target)
    value = element.val()

    if "" + parseInt(value) != value
      newValue = value.replace(/-/g, '') # remove all '-'
      newValue = -newValue if value.charAt(0) == '-'
      element.val newValue


  _moveByKeys: (event) ->
    switch event.keyCode
      when App.Lib.KeyCodes.up   then delta =  1
      when App.Lib.KeyCodes.down then delta = -1
      else
        return

    position = @model.get('position')
    newPosition = _.extend {}, position
    switch event.currentTarget.id
      when 'x-coord' then newPosition.x += delta
      when 'y-coord' then newPosition.y += delta

    @model.set
      position: newPosition


  _setPosition: (event) ->
    return unless event.keyCode is App.Lib.KeyCodes.enter

    @model.set
      position:
        x: Number(@$('#x-coord').val()) || 0
        y: Number(@$('#y-coord').val()) || 0


  keyPressed: (event) ->
    code = event.charCode
    isNumber = App.Lib.CharCodes[0] <= code <= App.Lib.CharCodes[9]
    isMinus = code == App.Lib.CharCodes.minus
    ok = not code or isNumber or isMinus

    event.preventDefault() unless ok


  _positionChanged: ->
    @_changeCoordinates @model.get('position')


  _changeCoordinates: (position) ->
    @$('#x-coord').val position.x
    @$('#y-coord').val position.y
