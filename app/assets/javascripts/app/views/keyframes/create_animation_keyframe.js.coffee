class App.Views.CreateAnimationKeyframe extends Backbone.View
  template: JST["app/templates/keyframes/create_animation_keyframe"]
  tagName: 'li'

  events:
    'click  .main': '_clicked'


  render: ->
    @$el.html(@template()).attr('data-is_animation', '1').addClass('placeholder')

    @


  _clicked: ->
    @collection.addNewKeyframe is_animation: true

    App.trackUserAction 'Added animation intro'
