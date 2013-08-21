#= require ./image_widget_context_menu

class App.Views.ButtonWidgetContextMenu extends App.Views.ImageWidgetContextMenu

  events: ->
    _.extend({}, super, {
      'click #button-widget-filename':              'showUpdateModal'
      'click #button-widget-disable':               'toggleDisable'
    })


  template: JST["app/templates/context_menus/button_widget_context_menu"]


  _render: ->
    @$el.html(@template(widget: @widget))
    @


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


  _moveSprite: (direction, pixels) ->
    x_oord = @widget.get('position').x
    y_oord = @widget.get('position').y
    point = @_measurePoint(direction, pixels, x_oord, y_oord)

    @_delayedSavePosition(point) if point?


  _setPosition: (point) ->
    @widget.set(position: { x: parseInt(point.x), y: parseInt(point.y) })


  _setScale: (scale_by) =>
    scale = @widget.get('scale') * 100
    if scale_by?
      if parseInt(scale) + scale_by < 10
        @_scaleCantBeSet()
        @$('#scale-amount').val(parseInt(scale))
        return
      else
        @$('#scale-amount').val(parseInt(scale) + scale_by)

    else
      if parseInt(@_currentScale()) < 10
        @_scaleCantBeSet()
        @$('#scale-amount').val(parseInt(scale))
        return
    @widget.set(scale: @_currentScale() / 100)
