##
# Sound player with play/pause control.
#
class App.Views.SoundPlayer extends Backbone.View
  template: JST['app/templates/assets/library/sound_player']

  events:
    'click .control': '_controlClicked'


  initialize: ->
    @player = null


  render: ->
    @$el.html @template(sound: @model)

    @


  remove: ->
    @player?.destroy()


  _controlClicked: (event) ->
    event.stopPropagation()

    @_ensurePlayerCreated()

    if @player.paused()
      @player.play()
      @_showStop()
    else
      @player.pause()
      @_showPlay()


  _ensurePlayerCreated: ->
    return if @player?

    @player = Popcorn("##{@model.cid}")
    @player.on 'ended', @_showPlay, @


  control: ->
    @_control ||= @$('.control')


  _showPlay: =>
    @control().   addClass('icon-play').removeClass('icon-stop')


  _showStop: ->
    @control().removeClass('icon-play').   addClass('icon-stop')
