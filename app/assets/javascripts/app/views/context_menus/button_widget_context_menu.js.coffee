#= require ./image_widget_context_menu

class App.Views.ButtonWidgetContextMenu extends App.Views.ImageWidgetContextMenu

  events: ->
    _.extend({}, super, {
      'click #button-widget-filename': 'showUpdateModal'
      'click #button-widget-disable':  'toggleDisable'
      'click .use-default':            'useDefaultImage'
    })


  template: JST["app/templates/context_menus/button_widget_context_menu"]


  initialize: ->
    super
    @widget.on 'change', @render, @


  render: ->
    @$el.html(@template(widget: @widget))
    @_disabledChanged()
    @


  remove: ->
    @widget.off 'change', @render, @
    super


  showUpdateModal: (event) ->
    event.stopPropagation()
    view = new App.Views.ButtonWidgetImagesSelector
      widget:     @widget
      collection: @widget.collection.storybook.images

    modal = App.modalWithView(view: view)
    modal.show()


  toggleDisable: (event) ->
    event.stopPropagation()
    if @widget.disabled()
      @widget.enable()
    else
      @widget.disable()


  useDefaultImage: (event) ->
    event.stopPropagation()
    @widget.useDefaultImage()


  _moveSprite: (direction, pixels) ->
    x_oord = @widget.get('position').x
    y_oord = @widget.get('position').y
    point = @_measurePoint(direction, pixels, x_oord, y_oord)

    @_delayedSavePosition(point) if point?


  _setPosition: (point) ->
    @_setObjectPosition(@widget, point)


  _setScale: (scale_by) =>
    @_setObjectScale(@widget, scale_by)

