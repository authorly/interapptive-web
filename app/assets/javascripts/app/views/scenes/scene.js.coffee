class App.Views.Scene extends Backbone.View
  template: JST["app/templates/scenes/scene"]
  tagName: 'li'

  initialize: ->
    @model.on 'change:preview', @updatePreview

  render: ->
    $(@el).html(@template(scene: @model))
    this

  updatePreview:  =>
    src = @model.preview.src()
    @$('.scene-frame img').remove()
    if src?
      @$('.scene-frame').append "<img src='#{src}'/>"
