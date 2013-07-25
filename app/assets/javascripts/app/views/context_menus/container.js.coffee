class App.Views.ContextMenuContainer extends Backbone.View

  initialize: ->
    @widgetContextMenu = null
    App.vent.on('activate:spriteWidget',  @renderWidgetContextMenu, @)
    #App.vent.on('activate:hotspotWidget', @renderWidgetContextMenu, @)
    #App.vent.on('activate:textWidget',    @renderWidgetContextMenu, @)

    App.vent.on('deactivate:spriteWidget',  @emptyWidgetContextMenu, @)
    #App.vent.on('deactivate:hotspotWidget', @emptyWidgetContextMenu, @)
    #App.vent.on('deactivate:textWidget',    @emptyWidgetContextMenu, @)


  render: ->
    @$el.append(@widgetContextMenu.render().el)
    @


  renderWidgetContextMenu: (widget) ->
    if @widgetContextMenu?
      @widgetContextMenu.remove()

    @$el.append('<ul id="context-menu"></ul>')
    @widgetContextMenu = new App.Views[widget.get('type') + 'ContextMenu'](widget: widget, el: @$('ul#context-menu'))
    @render()


  emptyWidgetContextMenu: ->
    @widgetContextMenu.remove()
    @widgetContextMenu = null
