# This widget factory works as a marshal for all widgets in all keyframes
# It should also function as a dispatcher to keyframe and to widgetlayer
# and as an interface to the toolbar. In short: it completely handles widget
# CRUD, dispatching where necessary.
#
# There's a lot of work to be done on it.

class WidgetDispatcher

  constructor: ->
    _.extend(@, Backbone.Events)

    @widgets = []

    @on('widget:touch:create widget:touch:edit', @handleTouchWidget)
    @on('widget:touch:update', @updateTouchWidget)
    @on('widget:highlight', @clearHighlights)
    @on('widget:unhighlight', @clearHighlights)

  # Iterators
  allButId: (id) ->
    _.reject(@widgets, (w) -> w.id == id)

  # Group actions
  clearHighlights: (id) ->
    if @widgets
      console.info "Unhighlighting everything but #{id}"
      widget.unHighlight for widget in @allButId(id)
    else
      console.warn "No widgets recorded."

  # Creators
  handleTouchWidget: (widget) ->
    unless widget
      widget = new App.Builder.Widgets.TouchWidget
      widget.setPosition(new cc.Point(300, 300))
      @_addWidget(widget)

    @openTouchModal(widget)

  # Modals
  openTouchModal: (widget) =>
    view = new App.Views.TouchZoneIndex(widget: widget)
    view.on('touch_select', @updateTouchWidget)
    App.modalWithView(view: view).show()
    # view.fetchImages()

  # Updaters
  updateTouchWidget: (result) =>
    #widget = result.widget
    #widget.setData()

    App.modalWithView().hide()
    view.off('touch_select', @updateTouchWidget)

  # TODO: Do we even need this?
  _addWidget: (widget) ->
    @widgets.push(widget)

    App.builder.widgetLayer.addWidget(widget)

    keyframe = App.currentKeyframe()
    keyframe.addWidget(widget)
    widget.on('change', -> keyframe.updateWidget(widget))


App.Builder.Widgets.WidgetDispatcher = new WidgetDispatcher()
