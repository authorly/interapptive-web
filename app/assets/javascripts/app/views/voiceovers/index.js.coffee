# This view is used for aligning text to audio which, in turn, allows for users
# to create word-by-word highlighting.
# The audio will be a voice that, when played, enables the users to drag/click
# word-by-word. As they click/drag over each word in sync with the associated audio,
# we accumulate an array of time intervals. Intervals are then used for highlighting
# word-by-word.
# RFCTR Create a Voiceover Backbone model and move model related things.
# @author dira, @date 2013-01-14
class App.Views.VoiceoverIndex extends Backbone.View
  template: JST['app/templates/voiceovers/index']

  events:
    'change input[type=file]':  'fileChanged'
    'click #upload':            'uploadAudio'
    'click .icon-edit':         'showUploadForm'
    'mousedown .word':          'mouseDownOnWord'
    'mouseover .word':          'mouseOverWord'
    'selectstart':              'cancelNativeHighlighting'
    'click #begin-alignment':   'clickBeginAlignment'
    'click #preview-alignment': 'clickPreviewAlignment'
    'click #accept-alignment':  'acceptAlignment'
    'click #reorder-text .reorder': 'enableSorting'
    'click #reorder-text .done':    'disableSorting'

  COUNTDOWN_LENGTH_IN_SECONDS: 5

  VOICEOVER_UPLOAD_ERROR: 'There was a problem uploading your file. Please try again.'


  initialize: (keyframe) ->
    @keyframe = keyframe
    @player = null

    @_alignmentInProgress = false
    @_mouseDown = false

    $(document).mouseup => @_mouseDown = false


  render: ->
    @$el.html(@template(keyframe: @keyframe))
    @initUploader()
    @initSorting()
    @pulsateArrowIcon()
    @findExistingVoiceover()
    @


  clickBeginAlignment: (event) =>
    event.preventDefault()

    if @_alignmentInProgress then @stopAlignment() else @startCountdown()


  acceptAlignment: (event) ->
    return if @$(event.currentTarget).hasClass('disabled')

    @keyframe.updateContentHighlightTimes @_collectTimeIntervals(),
      # TODO replace this with a 'done' event that the parent listens to
      # 2013-05-07 @dira
      success: -> App.vent.trigger 'hide:modal'


  clickPreviewAlignment: (event) =>
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
    @initMediaPlayer()
    @$('#countdown').jcountdown
      timestamp: endTime
      callback: (days, hours, minutes, seconds) =>
        if seconds is 0 and not countdownEnded
          @countdownEnded()
          countdownEnded = true


  stopAlignment: =>
    @player.pause(@player.duration())
    @enablePreview()
    @disableHelperArrow()
    @removeWordHighlights()


  countdownEnded: =>
    @_alignmentInProgress = true

    @removeWordHighlights()

    @player.play()
    @player.playbackRate(0.6)

    @$('#countdown').remove()
    @$('.word').removeClass('disabled')
    @$('i.icon-arrow-right.icon-black').removeClass('disabled')
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
      @disableHelperArrow() if @isFirstWord($wordEl)
      $wordEl.addClass('highlighted').attr('data-start', @_playerCurrentTimeInSeconds())

    false


  disableHelperArrow: ->
    @$('i.icon-arrow-right.icon-black').addClass('disabled')


  pulsateArrowIcon: ->
    speed = 900
    @$('i.icon-arrow-right.icon-black').effect 'pulsate',
      times: 1
    , speed, =>
      @pulsateArrowIcon()


  isFirstWord: (el) ->
    el.is('span:first-child') and el.parent().is('li:first-child')


  prevElHighlighted: (el) ->
    lastElWasHighlighted =
      el.is('span:first-child') and el.parent().prev().find('span:last-child').hasClass('highlighted')
    el.prev().hasClass('highlighted') or lastElWasHighlighted


  canHighlightEl: (el) ->
    @prevElHighlighted(el) or @isFirstWord(el)


  findExistingHighlightTimes: ->
    intervals = @keyframe.get('content_highlight_times')
    @enablePreview()
    return unless intervals?.length > 0

    $words = @$('.word')
    $.each $words, (index, word) =>
      @$(word).attr("data-start", "#{intervals[index]}")

    @enableAcceptAlignment()


  # RFCTR: Move to a Voiceover model
  findExistingVoiceover: ->
    $.getJSON @keyframe.voiceoverUrl(), (file) =>
      @initMediaPlayer()
      @player.play()

      if file.url? and file.name?
        @setExistingVoiceover(file)
        @findExistingHighlightTimes()
      else
        @noVoiceoverFound()


  setExistingVoiceover: (file) ->
    @$('.loading').hide()
    @$('.filename').css('display', 'inline-block')
      .addClass('uploaded')
    @$('.filename span').text(file.name)
    @setAudioPlayerSrc(file.url)
    @enableHighlighting()


  noVoiceoverFound: ->
    @$('.loading').hide()
    @$('.fileinput-button').removeClass('disabled')


  showUploadForm: ->
    @$('.filename').hide()
    @$('.fileinput-button').removeClass('disabled')


  fileChanged: (event) ->
    @$('#upload').show()
    @$('#voiceover-file button').removeClass('disabled')
    @$('.fileinput-button').addClass('disabled')

    path = @$(event.currentTarget).val()
    filename =  @_pathToFilename(path)
    @$('.filename span').text(filename)
      .parent().css('display', 'inline-block')


  uploadAudio: (event) ->
    return if @$(event.currentTarget).hasClass('disabled')
    event.preventDefault()

    @$('.loading').show()
    @$('#upload, .filename').hide()

    @voiceoverUploader.send()


  initUploader: ->
    @voiceoverUploader = new voiceoverUploader @$('#audio-file').get(0),
      url: @keyframe.voiceoverUrl()
      error: (event) =>
        alert @VOICEOVER_UPLOAD_ERROR
      success: (file)  =>
        @$('.loading').hide()
        @$('.filename').css('display', 'inline-block').addClass('uploaded')
        @$('.success').css('display', 'inline-block').delay(1300).fadeOut(700)

        _file = JSON.parse(file)
        @setAudioPlayerSrc(_file.url)
        @enableHighlighting()


  initMediaPlayer: =>
    @player = Popcorn('audio')
    @player.on 'ended', =>
      @disableHelperArrow()

      if @_previewingAlignment
        @previewingEnded()
      else
        @enableAcceptAlignment()
        @enablePreview()

      @$('.word.highlighted').removeClass('highlighted')
      @_showBeginHighlightingButton()
      @_alignmentInProgress = false


  initSorting: ->
    @$('#words').sortable
      update:   @updateOrder
      disabled: true


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


  setAudioPlayerSrc: (voiceoverUrl) ->
    @$('audio').attr('src', voiceoverUrl)


  showControls: ->
    @$('#controls').css('visibility', 'visible')


  hideControls: ->
    @$('#controls').css('visibility', 'hidden')


  stopVoiceover: =>
    @player.pause()


  _playerCurrentTimeInSeconds: ->
    Math.round(1000 * @player.currentTime()) / 1000


  _pathToFilename: (path) ->
    path.split('\\').pop()


  _collectTimeIntervals: ->
    _.map @$('.word'), (el) -> @$(el).data('start')


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
      .text('Stop Highlighting')
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
