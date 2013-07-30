class App.Views.ContextMenuContainer extends Backbone.View

  initialize: ->
    @widgetContextMenu = null
    App.vent.on('activate:spriteWidget activate:hotspotWidget',  @render, @)
    #App.vent.on('activate:textWidget',    @render, @)

    App.vent.on('deactivate:spriteWidget deactivate:hotspotWidget',  @empty, @)
    #App.vent.on('deactivate:textWidget',    @empty, @)


  render: (widget) ->
    @widgetContextMenu?.remove()

    @widgetContextMenu = new App.Views[widget.get('type') + 'ContextMenu'](widget: widget, id: 'context-menu')
    @$el.append(@widgetContextMenu.render().el)
    @


  empty: ->
    @widgetContextMenu.remove()
    @widgetContextMenu = null
