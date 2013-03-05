class App.Views.VideoPlayer extends Backbone.View
  template:  JST['app/templates/assets/videos/player']

  className: 'video-container'


  initialize: (video) ->
    @video = video


  render: ->
    @$el.html @template(video: @video)
    @
