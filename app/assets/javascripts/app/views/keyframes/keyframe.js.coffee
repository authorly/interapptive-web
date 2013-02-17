class App.Views.Keyframe extends Backbone.View
  template: JST["app/templates/keyframes/keyframe"]
  tagName: 'li'

  initialize: ->
    @text_list_view = new App.Views.TextWidgetIndex(model: @model, el: $('canvas'))
    @model.on('widget:text:create', @text_list_view.createText, @text_list_view)
    @model.on('widget:text:destroy', @text_list_view.removeText, @text_list_view)
    @model.on('hide_views',         @text_list_view.hide,       @text_list_view)
    @model.on('show_views',         @text_list_view.show,       @text_list_view)

    App.vent.on('disable:textWidgetView', @text_list_view.disableOtherTextWidgetViewsThan, @text_list_view)

  render: ->
    @$el.html(@template(keyframe: @model)).attr('data-id', @model.id)
    if @model.isAnimation()
      @$el.attr('data-is_animation', '1').addClass('animation')

    @text_list_view.render()
    @model.trigger('hide_views') # Hide text initially

    @

  remove: ->
    super
    @model.off('widget:text:create', @text_list_view.createText, @text_list_view)
    @model.off('widget:text:destroy', @text_list_view.removeText, @text_list_view)
    @model.off('hide_views',         @text_list_view.hide,       @text_list_view)
    @model.off('show_views',         @text_list_view.show,       @text_list_view)

    App.vent.off('disable:textWidgetView', @text_list_view.disableOtherTextWidgetViewsThan, @text_list_view)
    @text_list_view.empty()
