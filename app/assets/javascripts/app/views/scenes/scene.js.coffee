class App.Views.Scene extends Backbone.View
  template: JST["app/templates/scenes/scene"]

  tagName: 'li'

  initialize: ->
    @model.on 'change:preview', @updatePreview


  render: ->
    $(@el).html(@template(scene: @model)).attr('data-id', @model.id)
    if @model.isMainMenu()
      @$el.attr('data-is_main_menu', '1').addClass('main_menu')
    this


  updatePreview:  =>
    src = @model.preview.src()
    @$('.scene-frame img').remove()
    if src?
      @$('.scene-frame').append "<img src='#{src}'/>"
