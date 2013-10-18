class App.Views.ContextMenu extends Backbone.View

  events: ->
    'click':          '_clicked' # for widget layer TODO refactor
    'click  .remove': '_removeClicked'


  initialize: ->
    @widget = @options.widget


  remove: ->
    super


  getModel: ->
    @widget


  _clicked: (event) ->
    event.stopPropagation() # for widget layer #TODO refactor


  _removeClicked: (e) ->
    @widget.collection?.remove(@widget)


  _renderCoordinates: (coordinatesContainer) ->
    @coordinates?.remove()

    @coordinates = new App.Views.Coordinates
      model: @getModel()
    coordinatesContainer.html @coordinates.render()


  _removeCoordinates: ->
    @coordinates.remove()
