# This view is used for aligning text to audio which, in turn, allows for users
# to create word-by-word highlighting.
# The audio will be a voice that, when played, enables the users to drag/click
# word-by-word. As they click/drag over each word in sync with the associated audio,
# we accumulate an array of time intervals. Intervals are then used for highlighting
# word-by-word.
# RFCTR Create a Voiceover Backbone model and move model related things.
# @author dira, @date 2013-01-14
class App.Views.Voiceover extends Backbone.View
  template: JST['app/templates/voiceovers/voiceover']

  events:
    'mousedown .word':          'mouseDownOnWord'
    'mouseover .word':          'mouseOverWord'
    'selectstart':              'cancelNativeHighlighting'
    'click #begin-alignment':   'clickBeginAlignment'
    'click #preview-alignment': 'clickPreviewAlignment'
    'click #accept-alignment':  'acceptAlignment'
    'click #reorder-text .reorder': 'enableSorting'
    'click #reorder-text .done a':  'disableSorting'

  COUNTDOWN_LENGTH_IN_SECONDS: 5

  DEFAULT_PLAYBACK_RATE: 0.5


  initialize: ->
    @keyframe = @model
    @player = null
    @playbackRate = @DEFAULT_PLAYBACK_RATE

    @_alignmentInProgress = false
    @_mouseDown = false

    App.vent.on 'changed:voiceover_playback_rate', @_voiceoverPlaybackRateChanged, @

    $(document).mouseup => @_mouseDown = false


  render: ->
    @$el.html(@template(keyframe: @keyframe))
    @_initVoiceoverSelector()
    @_initVoiceoverPlaybackRateSlider()
    @_initSorting()
    @_attachKeyframEvents()
    @_findExistingVoiceover()
    @


  remove: ->
    console.log 'remove voiceover'
    @stopVoiceover()
    super


  clickBeginAlignment: (event) =>
    event.preventDefault()

    return unless @keyframe.hasText()
    return unless @keyframe.hasVoiceover()

    App.trackUserAction 'Began highlighting'

    if @_alignmentInProgress then @stopAlignment() else @startCountdown()


  acceptAlignment: (event) ->
    unless @keyframe.hasVoiceover()
      App.trackUserAction 'Cancelled highlighting (no audio)'
      App.vent.trigger('hide:modal')
      return

    @keyframe.updateContentHighlightTimes @_collectTimeIntervals(),
      # TODO replace this with a 'done' event that the parent listens to
      # 2013-05-07 @dira
      success: ->
        App.vent.trigger 'hide:modal'
        App.trackUserAction 'Completed highlighting'


  clickPreviewAlignment: (event) =>
    return unless @keyframe.hasText()
    return unless @keyframe.hasVoiceover()
    @previewOrStopPreview(event)
    @setHighlightTimesForWordEls()

    @_previewingAlignment = true


  previewOrStopPreview: (event) ->
    $el = @$(event.currentTarget)
    if $el.find('i').hasClass('icon-play')
      @player.play()
      @player.playbackRate(1.0)
      @disableBeginAlignment()
      @_showStopButton($el)
    else
      @stopAlignment()
      @_showPreviewButton($el)


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


  startCountdown: ->
    @_addCountdownDiv()
    @disableBeginAlignment()

    @disablePreview()
    @disableAcceptAlignment()
    @initCountdownElement()


  initCountdownElement: ->
    countdownEnded = false
    endTime = (new Date()).getTime() + @COUNTDOWN_LENGTH_IN_SECONDS * 1000
    @player.destroy()
    @enableMediaPlayer()
    @$('#countdown').jcountdown
      timestamp: endTime
      callback: (days, hours, minutes, seconds) =>
        if seconds is 0 and not countdownEnded
          @countdownEnded()
          countdownEnded = true


  stopAlignment: =>
    @player.pause(@player.duration())
    @enablePreview()
    @removeWordHighlights()


  countdownEnded: =>
    @_alignmentInProgress = true

    @removeWordHighlights()

    @player.play()
    @player.playbackRate(@playbackRate)

    @$('#countdown').remove()
    @$('.word').removeClass('disabled')
    @_showStopHighlightingButton()


  removeWordHighlights: =>
    @$('span.word.highlighted').removeClass('highlighted')


  cancelNativeHighlighting: ->
    false


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


  isFirstWord: (el) ->
    el.is('span:first-child') and el.parent().is('li:first-child')


  prevElHighlighted: (el) ->
    lastElWasHighlighted =
      el.is('span:first-child') and el.parent().prev().find('span:last-child').hasClass('highlighted')
    el.prev().hasClass('highlighted') or lastElWasHighlighted


  canHighlightEl: (el) ->
    not @alreadyHighlighted(el) and (@prevElHighlighted(el) or @isFirstWord(el))


  alreadyHighlighted: (el) ->
    el.hasClass('highlighted')


  findExistingHighlightTimes: ->
    intervals = @keyframe.get('content_highlight_times')
    @enablePreview()
    return unless intervals?.length > 0

    $words = @$('.word')
    $.each $words, (index, word) =>
      @$(word).attr("data-start", "#{intervals[index]}")

    @enableAcceptAlignment()


  setExistingVoiceover: (voiceover) ->
    @setAudioPlayerSrc(voiceover)
    @enableHighlighting()


  noVoiceoverFound: ->
    @setAudioPlayerSrc()
    @disablePreview()
    @disableBeginAlignment()


  enableMediaPlayer: =>
    if App.Lib.BrowserHelper.canPlayVorbis()
      @player = Popcorn('#media-player-ogg')
    else
      @player = Popcorn('#media-player-mp3')

    @player.on 'ended', =>

      if @_previewingAlignment
        @previewingEnded()
      else
        @enableAcceptAlignment()
        @enablePreview()

      @$('.word.highlighted').removeClass('highlighted')
      @_showBeginHighlightingButton()
      @_alignmentInProgress = false


  enableSorting: ->
    @$('#words').sortable "option", "disabled", false
    @$('#words li').addClass('grab')
    @$('#reorder-text .reorder').hide()
    @$('#reorder-text .done').show()
    @hideControls()


  disableSorting: ->
    @$('#words').sortable "option", "disabled", true
    @$('#words li').removeClass('grab')
    @$('#reorder-text .reorder').show()
    @$('#reorder-text .done').hide()
    @showControls()


  updateOrder: =>
    zero = (new App.Models.TextWidget).get('z_order') || 0
    @$('#words li').each (index, element) =>
      element = $(element)

      if (id = element.data('id'))? && (text = @keyframe.widgets.get(id))?
        text.set {z_order: zero + index}, silent: true

    @keyframe.widgets.trigger 'change'


  previewingEnded: ->
    @_previewingAlignment = false
    @enableHighlighting()
    @_showPreviewButton(@$('#preview-alignment'))


  enablePreview: ->
    @$('#preview-alignment').removeClass('disabled')


  disablePreview: ->
    @$('#preview-alignment').addClass('disabled')


  enableAcceptAlignment: ->
    @$('#accept-alignment').removeClass('disabled')


  disableAcceptAlignment: ->
    @$('#accept-alignment').addClass('disabled')


  enableHighlighting: ->
    @$('#begin-alignment').removeClass('disabled')


  disableBeginAlignment: ->
    @$('#begin-alignment').addClass('disabled')


  setAudioPlayerSrc: ->
    if arguments.length > 0
      @$('audio#media-player-mp3').attr('src', arguments[0].get('mp3url'))
      @$('audio#media-player-ogg').attr('src', arguments[0].get('oggurl'))
    else
      @$('audio').attr('src', '')


  showControls: ->
    @$('#controls').css('visibility', 'visible')


  hideControls: ->
    @$('#controls').css('visibility', 'hidden')


  stopVoiceover: =>
    @_detachKeyframeEvents()
    @player.pause()


  _findExistingVoiceover: ->
    if (voiceover = @keyframe.voiceover())?
      @setExistingVoiceover(voiceover)
      @findExistingHighlightTimes()
    else
      @noVoiceoverFound()


  _initVoiceoverSelector: ->
    @voiceoverSelector = new App.Views.VoiceoverSelector
      keyframe: @keyframe
      collection: @keyframe.scene.storybook.sounds
      el: @$('#voiceover-selector-container')

    @voiceoverSelector.render()


  _initVoiceoverPlaybackRateSlider: ->
    @voiceoverPlaybackRateSlider = new App.Views.VoiceoverPlaybackRateSlider
      playbackRate: @playbackRate
      el: @$('#voiceover-playback-rate-slider-container')

    @voiceoverPlaybackRateSlider.render()


  _attachKeyframEvents: ->
    @keyframe.on('change:voiceover_id', @_findExistingVoiceover, @)


  _detachKeyframeEvents: ->
    @keyframe.off('change:voiceover_id', @_findExistingVoiceover, @)


  _initSorting: ->
    @$('#words').sortable
      update:   @updateOrder
      disabled: true


  _playerCurrentTimeInSeconds: ->
    Math.round(1000 * @player.currentTime()) / 1000


  _collectTimeIntervals: ->
    intervals = _.map @$('.word'), (el) -> @$(el).data('start')
    return intervals if _.every(intervals, (interval) -> interval? && interval != "undefined" && interval != "null")
    []


  _showStopButton: ($button) ->
    $button.find('span')
      .text('Stop')
      .parent().find('i')
      .removeClass('icon-play')
      .addClass('icon-stop')


  _showPreviewButton: ($button) ->
    $button.find('span')
      .text('Preview')
      .parent().find('i')
      .removeClass('icon-stop')
      .addClass('icon-play')


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


  _addCountdownDiv: ->
    @$('#words').after('<div id="countdown"></div>')
      .find('span.word')
      .addClass('disabled')


  _voiceoverPlaybackRateChanged: (value) ->
    @playbackRate = value
    @player.playbackRate(value)