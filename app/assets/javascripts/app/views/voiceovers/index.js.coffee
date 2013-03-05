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
     # 'click #accept-alignment':   'acceptAlignment'

  COUNTDOWN_LENGTH_IN_SECONDS: 5


  initialize: (keyframe) ->
    @keyframe = keyframe

    @_canManuallyAlign = false
    @_mouseDown = false
    @player = null

    $(document).mouseup => @_mouseDown = false


  render: ->
    @$el.html(@template(keyframe: @keyframe))
    @initUploader()
    @pulsateArrowIcon()
    @findExistingVoiceover()
    @


  clickBeginAlignment: (event) =>
    event.preventDefault()

    if @_canManuallyAlign then @stopAlignment() else @startCountdown()


  startCountdown: ->
    @$('#words').after('<div id="countdown"></div>')
      .find('span.word')
      .addClass('disabled')
    @$('#begin-alignment').addClass('disabled')

    countdownEnded = false
    endTime = (new Date()).getTime() + @COUNTDOWN_LENGTH_IN_SECONDS * 1000
    @$('#countdown').jcountdown
      timestamp: endTime
      callback: (days, hours, minutes, seconds) =>
        if seconds is 0 and not countdownEnded
          @countdownEnded()
          countdownEnded = true


  stopAlignment: =>
    @enablePreview()
    @disableHelperArrow()
    @removeWordHighlights()
    @player.pause(@player.duration())


  countdownEnded: =>
    @removeWordHighlights()

    @player.play()
    @player.playbackRate(0.6)

    @$('#countdown').remove()
    @$('.word').removeClass('disabled')
    @$('i.icon-arrow-right.icon-black').removeClass('disabled')
    @$('#begin-alignment').removeClass('disabled')
      .find('span')
      .text('Stop Highlighting')
      .parent().find('i')
      .removeClass('icon-exclamation-sign')
      .addClass('icon-stop')

    @_canManuallyAlign = true


  removeWordHighlights: =>
    $('span.word.highlighted').removeClass('highlighted')


  cancelNativeHighlighting: ->
    false


  mouseOverWord: (event) =>
    return false unless @_canManuallyAlign

    $wordEl = @$(event.currentTarget)
    if @_mouseDown and @canHighlightEl($wordEl)
      $wordEl.addClass('highlighted').attr('data-start', @_playerCurrentTimeInSeconds())


  mouseDownOnWord: (event) =>
    return false unless @_canManuallyAlign

    @_mouseDown = true

    $wordEl = @$(event.currentTarget)
    if @canHighlightEl($wordEl)
      @disableHelperArrow() if @isFirstWord($wordEl)
      $wordEl.addClass('highlighted').attr('data-start', @_playerCurrentTimeInSeconds())

    false


  disableHelperArrow: ->
    @$('i.icon-arrow-right.icon-black').addClass('disabled')


  pulsateArrowIcon: ->
    @$('i.icon-arrow-right.icon-black').effect 'pulsate',
      times: 1
    , 900, =>
       #repeat after pulsating
      @pulsateArrowIcon()


  isFirstWord: (el) ->
    el.is('span:first-child') and el.parent().is('li:first-child')


  prevElHighlighted: (el) ->
    lastElWasHighlighted =
      el.is('span:first-child') and el.parent().prev().find('span:last-child').hasClass('highlighted')
    el.prev().hasClass('highlighted') or lastElWasHighlighted


  canHighlightEl: (el) ->
    @prevElHighlighted(el) or @isFirstWord(el)


  # RFCTR: Move to a Voiceover model
  findExistingVoiceover: ->
    $.getJSON @keyframe.voiceoverUrl(), (file) =>
      @initMediaPlayer()

      if file.url? and file.name?
        @setExistingVoiceover(file)
      else
        @noVoiceoverFound()


  setExistingVoiceover: (file) ->
    @$('.loading').hide()
    @$('.filename').css('display', 'inline-block')
      .addClass('uploaded')
    @$('.filename span').text(file.name)
    @$('#begin-alignment').removeClass('disabled')
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
        console.log "Error uploading"
      success: (file)  =>
        @$('.loading').hide()
        @$('.filename').css('display', 'inline-block').addClass('uploaded')
        @$('.success').css('display', 'inline-block').delay(1300).fadeOut(700)

        _file = JSON.parse(file)
        @setAudioPlayerSrc(_file.url)
        @enableHighlighting()



  initMediaPlayer: =>
    @player = Popcorn('audio')
    @player.play().on 'ended', => @voiceoverEnded()


  voiceoverEnded: ->
    if @_previewingAlignment
      @previewingEnded()
    else
      @enablePreview()

    @$('.word.highlighted').removeClass('highlighted')
    @$('#begin-alignment').find('span')
      .text('Begin Highlighting')
      .parent().find('i')
      .removeClass('icon-stop')
      .addClass('icon-exclamation-sign')

    @_canManuallyAlign = false


  previewingEnded: ->
    @_previewingAlignment = false
    @$('#begin-alignment').removeClass('disabled')
    @$('#preview-alignment').find('span')
      .text('Preview')
      .parent().find('i')
      .removeClass('icon-stop')
      .addClass('icon-play')


  enablePreview: ->
    @$('#preview-alignment').removeClass('disabled')


  disablePreview: ->
    @$('#preview-alignment').addClass('disabled')


  enableHighlighting: ->
    @$('#begin-alignment').removeClass('disabled')


  setAudioPlayerSrc: (voiceoverUrl) ->
    @$('audio').attr('src', voiceoverUrl)


  clickPreviewAlignment: (event) ->
    $el = @$(event.currentTarget)
    if $el.find('i').hasClass('icon-play')
      @$('#begin-alignment').addClass('disabled')
      $el.find('span')
        .text('Stop')
        .parent().find('i')
        .removeClass('icon-play')
        .addClass('icon-stop')
    else
      $el.find('span')
        .text('Preview')
        .parent().find('i')
        .removeClass('icon-stop')
        .addClass('icon-play')

    # Can this be 1 line? -C.W 3.5.2013
    $words = @$('.word')
    $words.removeClass('highlighted')

    unless @_initialized
      @_initialized = true

      $.each $words, (index, word) =>
        @$(word).attr("id", "word-#{index}")

        if @$(words[index + 1]).length > 0
          endTime = parseFloat(@$($words[index + 1]).attr('data-start'))
        else
          endTime = parseFloat(@$(word).attr('data-start')) + 1

        @player.footnote
          start:      @$(word).attr('data-start')
          end:        endTime
          text:       ''
          target:     "word-#{index}"
          effect:     'applyclass'
          applyclass: 'highlighted'

    @player.play()
    @player.playbackRate(1.0)

    @_previewingAlignment = true


  _playerCurrentTimeInSeconds: ->
    Math.round(1000 * @player.currentTime()) / 1000


  _pathToFilename: (path) ->
    path.split('\\').pop()


  # acceptAlignment: (e) ->
  #   wordTimeIntervals = @collectTimeIntervals()
  #   keyframe = App.currentSelection.get('keyframe')
  #   keyframe.updateContentHighlightTimes wordTimeIntervals,
  #     success: -> App.modalWithView().hide()


  # collectTimeIntervals: ->
  #   @_intervals = []
  #
  #   words = @$('ul li span')
  #   $.each words, (index, wordEl) =>
  #     @_intervals.push $(wordEl).data('start')
  #
  #   @_intervals