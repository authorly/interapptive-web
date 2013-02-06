class App.Views.PaletteContainer extends Backbone.View

  template: JST["app/templates/palettes/container"]

  initialize: ->
    @view = @options.view

    @render()


  render: ->
    @$el.html @template(title: @options.title)
    @$el.append @view.render().el

    @initDraggable()
    @initResizable() if @options.resizable
    @view.makeSortable() if @view.makeSortable?

    @


  initDraggable: ->
    @$el.draggable
      containment: $('#main')
      snap:        true
      handle:     '.handler'
      drag: (event, ui) ->
        yBoundary = $('header').innerHeight()
        if ui.position.top < yBoundary then ui.position.top = yBoundary


  initResizable: ->
    width = @$el.width()
    @$el.resizable
      minWidth:    width
      maxWidth:    width + 180
      alsoResize:  @options.alsoResize || false
      containment: 'body'
