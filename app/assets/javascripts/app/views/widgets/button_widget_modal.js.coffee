class App.Views.ButtonWidgetModal extends Backbone.View
  template: JST["app/templates/widgets/button_images_modal"]

  render: ->
    @selector = new App.Views.ButtonWidgetImagesSelector
      model: @model

    @$el.html @template(model: @model)
    @$('.modal-body').append @selector.render().el

    @


  remove: ->
    @selector.remove()
    super
