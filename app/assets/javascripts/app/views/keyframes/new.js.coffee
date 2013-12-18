class App.Views.NewKeyframe extends Backbone.View
  template: JST["app/templates/keyframes/new"]

  className: 'new-keyframe'

  events:
    'click': 'newKeyframe'


  render: ->
    @$el.html @template()
    @


  newKeyframe: ->
    @options.scene.addNewKeyframe({})
    @$el.siblings('ul').animate
      scrollLeft: 99999
    , 'fast'

    App.trackUserAction 'Added keyframe'