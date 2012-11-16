class App.Views.VideoPlayer extends Backbone.View
  className: 'video-container'
  template: JST["app/templates/assets/videos/player"]

  initialize: (video) ->
    @video = video

  render: ->
    $(@el).html(@template(video: @video))
    this
