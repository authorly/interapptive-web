class App.Views.ContextMenu extends Backbone.View

  events: ->
    'click':          '_clicked' # for widget layer TODO refactor
    'click  .remove': '_removeClicked'


  initialize: ->
    @widget = @options.widget
    App.trackUserAction 'Selected widget', type: @widget.get('type')


  remove: ->
    super


  getModel: ->
    @widget


  _clicked: (event) ->
    event.stopPropagation() # for widget layer #TODO refactor


  _removeClicked: (e) ->
    App.trackUserAction 'Removed widget',
      type: @widget.get('type')
      source: 'context menu'
    @widget.collection?.remove(@widget)


  _renderCoordinates: (coordinatesContainer) ->
    @coordinates?.remove()

    @coordinates = new App.Views.Coordinates
      model: @getModel()
    coordinatesContainer.html @coordinates.render()


  _removeCoordinates: ->
    @coordinates.remove()
