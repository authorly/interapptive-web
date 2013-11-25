#= require ./abstract_voiceover_controls

class App.Views.BasicVoiceoverControls extends App.Views.AbstractVoiceoverControls
  template: JST['app/templates/voiceovers/basic_voiceover_controls']

  events:
    'mousedown .word':              'mouseDownOnWord'
    'mouseover .word':              'mouseOverWord'
    'click #begin-alignment':       'clickBeginAlignment'
    'click #reorder-text .reorder': 'enableSorting'
    'click #reorder-text .done a':  'disableSorting'

  DEFAULT_PLAYBACK_RATE: 0.5
  COUNTDOWN_LENGTH_IN_SECONDS: 5

  initialize: ->
    @keyframe = @model
    @playbackRate = @DEFAULT_PLAYBACK_RATE
    @_alignmentInProgress = false
    @_mouseDown = false

    $(document).mouseup => @_mouseDown = false
    @listenTo(App.vent, 'changed:voiceover_playback_rate', @_voiceoverPlaybackRateChanged)


  render: ->
    @$el.html(@template(keyframe: @keyframe))
    @_initVoiceoverPlaybackRateSlider()
    @_initSorting()
    @


  remove: ->
    @voiceoverPlaybackRateSlider.remove()
    @stopListening(App.vent, 'change:voiceover_playback_rate', @_voiceoverPlaybackRateChanged)
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

    App.vent.trigger('disable:voiceoverPreview')
    App.vent.trigger('disable:acceptVoiceoverAlignment')
    @initCountdownElement()


  initCountdownElement: ->
    countdownEnded = false
    endTime = (new Date()).getTime() + @COUNTDOWN_LENGTH_IN_SECONDS * 1000
    @player.destroy()
    App.vent.trigger('enable:voiceoverMediaPlayer')
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


  setHighlightTimesForWordEls: ->
    $words = @$('.word')
    $words.removeClass('highlighted')
    $.each $words, (index, word) =>
      @$(word).attr("id", "word-#{index}")
      startTime = @$(word).attr('data-start')
      if startTime
        if @$($words[index + 1]).length > 0
          endTime = parseFloat(@$($words[index + 1]).attr('data-start'))

        else
          endTime = parseFloat(startTime) + 1

        @player.footnote
          start:      startTime
          end:        endTime
          text:       ''
          target:     "word-#{index}"
          effect:     'applyclass'
          applyclass: 'highlighted'


  countdownEnded: =>
    @_alignmentInProgress = true

    @removeWordHighlights()

    @player.play()
    @player.playbackRate(@playbackRate)

    @$('#countdown').remove()
    @$('.word').removeClass('disabled')
    @_showStopHighlightingButton()


  collectTimeIntervals: ->
    intervals = _.map @$('.word'), (el) -> @$(el).data('start')
    return intervals if _.every(intervals, (interval) -> interval? && interval != "undefined" && interval != "null")
    []


  findExistingHighlightTimes: ->
    intervals = @keyframe.get('content_highlight_times')
    App.vent.trigger('enable:voiceoverPreview')
    return unless intervals?.length > 0

    $words = @$('.word')
    $.each $words, (index, word) =>
      @$(word).attr("data-start", "#{intervals[index]}")

    App.vent.trigger('enable:acceptVoiceoverAlignment')


  enableSorting: ->
    @$('#words').sortable "option", "disabled", false
    @$('#words li').addClass('grab')
    @$('#reorder-text .reorder').hide()
    @$('#reorder-text .done').show()
    App.vent.trigger('hide:voiceoverControls')


  disableSorting: ->
    @$('#words').sortable "option", "disabled", true
    @$('#words li').removeClass('grab')
    @$('#reorder-text .reorder').show()
    @$('#reorder-text .done').hide()
    App.vent.trigger('show:voiceoverControls')


  stopAlignment: =>
    @player.pause(@player.duration())
    App.vent.trigger('enable:voiceoverPreview')
    @removeWordHighlights()


  removeWordHighlights: =>
    @$('span.word.highlighted').removeClass('highlighted')


  disableBeginAlignment: ->
    @$('#begin-alignment').addClass('disabled')


  enableBeginAlignment: ->
    @$('#begin-alignment').removeClass('disabled')


  resetHighlightControls: ->
    @$('.word.highlighted').removeClass('highlighted')
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

    @voiceoverPlaybackRateSlider.render()


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
