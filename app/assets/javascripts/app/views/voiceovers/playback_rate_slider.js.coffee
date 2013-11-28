# This view is for adjusting the speed at which voiceover audio can be played
# while highlighting text. Decreasing the rate allows the user a better
# opportunity to accurately highlight the text to match the audio.
#
# @author whitman, @date 2013-9-17
class App.Views.VoiceoverPlaybackRateSlider extends Backbone.View
  template: JST['app/templates/voiceovers/playback_rate_slider']

  initialize: ->
    @defaultPlaybackRate = @options.playbackRate


  render: ->
    @$el.html(@template(playbackRate: @defaultPlaybackRate))
    @_initSlider()
    @


  _initSlider: ->
    @$('#playback-rate-slider').slider
      value: @defaultPlaybackRate
      step:  0.01
      max:   1.0
      min:   0.5
      slide: (event, ui) => @_sliderMoved(ui.value)


  _sliderMoved: (value) ->
    valueAsPercent = "#{Math.round(value*100)}%"
    @$('#playback-rate').html(valueAsPercent)

    @trigger('change:voiceover_playback_rate', value)
