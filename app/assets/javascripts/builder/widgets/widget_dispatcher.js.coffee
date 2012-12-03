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

    @on('widget:touch:create widget:touch:edit', @instantiateTouchWidget)
    @on('widget:touch:update', @updateTouchWidget)
    @on('widget:highlight', @clearHighlights)
    @on('widget:unhighlight', @clearHighlights)

  # Iterators
  allButId: (id) ->
    _.reject(@widgets, (w) -> w.id == id)

  # Group actions
  clearHighlights: (id) ->
    if @widgets
      widget.unHighlight for widget in @allButId(id)
    else

  # Creators
  instantiateTouchWidget: (widget) ->
    unless widget?.id
      widget = {}

    @openTouchModal(widget)

  createWidget: (widget) ->
    widget = new App.Builder.Widgets.TouchWidget
    widget.setPosition(new cc.Point(300, 400))
    @_addSceneWidget(widget)
    widget

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


  _addSceneWidget: (widget) =>
    @widgets.push(widget)

    App.builder.widgetLayer.addWidget(widget)

    scene = App.currentScene()
    scene.addWidget(widget)
    widget.on('change', -> scene.updateWidget(widget))


App.Builder.Widgets.WidgetDispatcher = new WidgetDispatcher()
