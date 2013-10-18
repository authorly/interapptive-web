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
    @listenTo @widget, 'change:image_id', @render


  render: ->
    @$el.html @template(widget: @widget)
    @_renderCoordinates @$('#button-widget-coordinates')
    @


  remove: ->
    @_removeCoordinates()
    super


  showUpdateModal: (event) ->
    view = new App.Views.ButtonWidgetImagesSelector
      widget:     @widget
      collection: @widget.collection.storybook.images

    modal = App.modalWithView(view: view)
    modal.show()


  toggleDisable: (event) ->
    if @widget.disabled()
      @widget.enable()
    else
      @widget.disable()


  useDefaultImage: (event) ->
    @widget.useDefaultImage()

