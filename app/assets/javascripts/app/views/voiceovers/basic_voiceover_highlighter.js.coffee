#= require ./abstract_voiceover_highlighter

# This view enables users to drag/click on words of the keyframe text.
# As they click/drag over each word in sync with the associated audio,
# we accumulate an array of time intervals. Intervals are then used for
# highlighting word-by-word.

class App.Views.BasicVoiceoverHighlighter extends App.Views.AbstractVoiceoverHighlighter
  template: JST['app/templates/voiceovers/basic_voiceover_highlighter']

  events:
    'mousedown .word':              'mouseDownOnWord'
    'mouseover .word':              'mouseOverWord'
    'click #begin-alignment':       'clickBeginAlignment'
    'click #reorder-text .reorder': 'enableSorting'
    'click #reorder-text .done a':  'disableSorting'

  COUNTDOWN_LENGTH_IN_SECONDS: 5

  initialize: ->
    super
    @playbackRate = 0.5
    @_alignmentInProgress = false
    @_mouseDown = false

    $(document).mouseup => @_mouseDown = false


  render: ->
    @$el.html(@template(keyframe: @keyframe))
    @_initVoiceoverPlaybackRateSlider()
    @_initSorting()
    @


  _wordProcessor: (index, word) =>
    @$(word).attr("data-start", "#{@intervals[index]}")


  remove: ->
    @voiceoverPlaybackRateSlider.remove()
    super


  clickBeginAlignment: (event) =>
    event.preventDefault()

    return unless @keyframe.hasText()
    return unless @keyframe.hasVoiceover()

    App.trackUserAction 'Began highlighting'

    if @_alignmentInProgress then @stopAlignment() else @startCountdown()


  mouseOverWord: (event) =>
    return false unless @_alignmentInProgress

    $wordEl = @$(event.currentTarget)
    if @_mouseDown and @canHighlightEl($wordEl)
      $wordEl.addClass('highlighted').attr('data-start', @_playerCurrentTimeInSeconds())


  mouseDownOnWord: (event) =>
    return false unless @_alignmentInProgress
    @_mouseDown = true

    $wordEl = @$(event.currentTarget)
    if @canHighlightEl($wordEl)
      $wordEl.addClass('highlighted').attr('data-start', @_playerCurrentTimeInSeconds())
    false


  startCountdown: ->
    @_addCountdownDiv()
    @disableBeginAlignment()

    @trigger('disable:voiceoverPreview')
    @trigger('disable:acceptVoiceoverAlignment')
    @initCountdownElement()


  initCountdownElement: ->
    countdownEnded = false
    endTime = (new Date()).getTime() + @COUNTDOWN_LENGTH_IN_SECONDS * 1000
    @player.destroy()
    @trigger('enable:voiceoverMediaPlayer')
    @$('#countdown').jcountdown
      timestamp: endTime
      callback: (days, hours, minutes, seconds) =>
        if seconds is 0 and not countdownEnded
          @countdownEnded()
          countdownEnded = true


  canHighlightEl: (el) ->
    not @alreadyHighlighted(el) and (@prevElHighlighted(el) or @isFirstWord(el))


  alreadyHighlighted: (el) ->
    el.hasClass('highlighted')


  prevElHighlighted: (el) ->
    lastElWasHighlighted =
      el.is('span:first-child') and el.parent().prev().find('span:last-child').hasClass('highlighted')
    el.prev().hasClass('highlighted') or lastElWasHighlighted


  isFirstWord: (el) ->
    el.is('span:first-child') and el.parent().is('li:first-child')


  updateOrder: =>
    zero = (new App.Models.TextWidget).get('z_order') || 0
    @$('#words li').each (index, element) =>
      element = $(element)

      if (id = element.data('id'))? && (text = @keyframe.widgets.get(id))?
        text.set {z_order: zero + index}, silent: true

    @keyframe.widgets.trigger 'change'


  countdownEnded: =>
    @_alignmentInProgress = true

    @removeWordHighlights()

    @player.play()
    @player.playbackRate(@playbackRate)

    @$('#countdown').remove()
    @$('.word').removeClass('disabled')
    @_showStopHighlightingButton()


  enableSorting: ->
    @$('#words').sortable "option", "disabled", false
    @$('#words li').addClass('grab')
    @$('#reorder-text .reorder').hide()
    @$('#reorder-text .done').show()
    @trigger('hide:voiceoverControls')


  disableSorting: ->
    @$('#words').sortable "option", "disabled", true
    @$('#words li').removeClass('grab')
    @$('#reorder-text .reorder').show()
    @$('#reorder-text .done').hide()
    @trigger('show:voiceoverControls')


  disableBeginAlignment: ->
    @$('#begin-alignment').addClass('disabled')


  enableBeginAlignment: ->
    @$('#begin-alignment').removeClass('disabled')


  resetHighlightControls: ->
    super
    @_showBeginHighlightingButton()
    @_alignmentInProgress = false


  _playerCurrentTimeInSeconds: ->
    Math.round(1000 * @player.currentTime()) / 1000


  _initSorting: ->
    @$('#words').sortable
      update:   @updateOrder
      disabled: true


  _initVoiceoverPlaybackRateSlider: ->
    @voiceoverPlaybackRateSlider = new App.Views.VoiceoverPlaybackRateSlider
      playbackRate: @playbackRate
      el: @$('#voiceover-playback-rate-slider-container')
    @_attachPlaybackSliderEvents()

    @voiceoverPlaybackRateSlider.render()


  _attachPlaybackSliderEvents: ->
    @listenTo(@voiceoverPlaybackRateSlider, 'change:voiceover_playback_rate', @_voiceoverPlaybackRateChanged)


  _voiceoverPlaybackRateChanged: (value) ->
    @playbackRate = value
    @player.playbackRate(value)


  _addCountdownDiv: ->
    @$('#words').after('<div id="countdown"></div>')
      .find('span.word')
      .addClass('disabled')


  _showStopHighlightingButton: ->
    @$('#begin-alignment').removeClass('disabled')
      .find('span')
      .text('Cancel Highlighting')
      .parent().find('i')
      .removeClass('icon-exclamation-sign')
      .addClass('icon-stop')


  _showBeginHighlightingButton: ->
    @$('#begin-alignment').find('span')
      .text('Begin Highlighting')
      .parent().find('i')
      .removeClass('icon-stop')
      .addClass('icon-exclamation-sign')
