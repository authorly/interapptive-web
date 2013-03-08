class App.Views.VideoPlayer extends Backbone.View
  template:  JST['app/templates/assets/videos/player']

  className: 'video-container'


  initialize: (video) ->
    @video = video
    @on('pause', @_pauseVideo, @)


  render: ->
    @$el.html @template(video: @video)
    @


  _pauseVideo: ->
    $video = $('.video-player')
    if $video.length > 0
      $video[0].pause()
      $('.content-modal').show()
      @off('pause', @_pauseVideo, @)
