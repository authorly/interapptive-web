class App.Views.ContextMenu extends Backbone.View

  events: ->
    'click':          '_clicked' # for widget layer TODO refactor
    'click  .remove': '_removeClicked'


  initialize: ->
    @widget = @options.widget
    @_addListeners()


  remove: ->
    @_removeListeners()
    super


  getModel: ->
    @widget


  _clicked: (event) ->
    event.stopPropagation() # for widget layer #TODO refactor


  _addListeners: ->
    $('body').on  'keyup', @_arrowPressed


  _removeListeners: ->
    $('body').off 'keyup', @_arrowPressed


  _removeClicked: (e) ->
    @widget.collection?.remove(@widget)


  _renderCoordinates: (coordinatesContainer) ->
    @coordinates?.remove()

    @coordinates = new App.Views.Coordinates
      model: @getModel()
    coordinatesContainer.html @coordinates.render()


  _removeCoordinates: ->
    @coordinates.remove()


  _arrowPressed: (event) =>
    return unless event.target == document.body

    delta = 10
    dx = 0; dy = 0
    switch event.keyCode
      when App.Lib.Keycodes.left  then dx = -delta
      when App.Lib.Keycodes.up    then dy =  delta
      when App.Lib.Keycodes.right then dx =  delta
      when App.Lib.Keycodes.down  then dy = -delta
      else return

    position = @getModel().get('position')
    @getModel().set
      position:
        x: position.x + dx
        y: position.y + dy


