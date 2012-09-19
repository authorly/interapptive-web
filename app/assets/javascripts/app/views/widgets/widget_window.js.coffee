class App.Views.WidgetWindow extends Backbone.View

  initialize: ->
    @_view = @options.view
    @_isResizable = @options.resizable

    @render()


  render: ->
    $(@el).append(@_view.render().el)

    @initResizable() unless @_isResizable is false

    @initDraggable()

    @_view.makeSortable() if @_view instanceof App.Views.ActiveSpritesList

    @createHandlerEl()

    this


  createHandlerEl: ->
    $('<div></div>').prependTo(@el).addClass('handler')


  initDraggable: ->
    options = {
        containment: $('#main')
        snap:        true
        handle:     '.handler'
        drag: (event, ui) ->
          yBoundary = $('header').innerHeight()
          if ui.position.top < yBoundary then ui.position.top = yBoundary
      }

    $(@el).draggable(options)


  initResizable: ->
    $el = $(@el)

    options = {
        minWidth:    $el.width()
        maxWidth:    $el.width() + 180
        alsoResize:  '#active-sprites-window ul li span'
        containment: 'body'
      }

    $el.resizable(options)