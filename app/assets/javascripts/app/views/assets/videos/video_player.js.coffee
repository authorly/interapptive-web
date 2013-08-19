class App.Views.VideoPlayer extends Backbone.View
  template:  JST['app/templates/assets/videos/player']

  className: 'video-container'


  initialize: (video) ->
    @on('pause', @_pauseVideo, @)


  render: ->
    @$el.html @template(video: @model)
    @


  _pauseVideo: ->
    $video = $('.video-player')
    if $video.length > 0
      $video[0].pause()
      @off('pause', @_pauseVideo, @)


  hideCallback: ->
    @_pauseVideo()
    $('.videos').trigger('click')
