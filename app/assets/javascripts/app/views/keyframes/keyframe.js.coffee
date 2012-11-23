class App.Views.Keyframe extends Backbone.View
  template: JST["app/templates/keyframes/keyframe"]
  tagName: 'li'

  render: ->
    @$el.html(@template(keyframe: @model)).attr('data-id', @model.id)
    if @model.isAnimation()
      @$el.attr('data-is_animation', '1')

    this
