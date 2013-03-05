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
    'change input[type=file]': 'fileChanged'
    'click #upload':           'uploadAudio'
    'click .icon-edit':        'showUploadForm'
    'mousedown .word':         'mouseDownOnWord'
    'mouseover .word':         'mouseOverWord'
    'selectstart':             'cancelNativeHighlighting'
    'click #begin-alignment':  'clickBeginOrStopAlignment'
     # 'click #preview-alignment':  'playWithAlignment'
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


  clickBeginOrStopAlignment: (event) =>
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
      url:                @keyframe.voiceoverUrl()
      error: (event) =>   @uploadErrored(event)
      success: (file)  => @uploadFinished(file)


  initMediaPlayer: =>
    @player = Popcorn('audio')
    @player.play().on 'ended', => @voiceoverEnded()


  voiceoverEnded: ->
    @$('.word.highlighted').removeClass('highlighted')
    @$('#begin-alignment').find('span')
      .text('Begin Highlighting')
      .parent().find('i')
      .removeClass('icon-stop')
      .addClass('icon-exclamation-sign')

    @_canManuallyAlign = false


  uploadErrored: (event) ->
    console.log "Error uploading"


  uploadFinished: (file) ->
    @$('.loading').hide()
    @$('.filename').css('display', 'inline-block').addClass('uploaded')
    @$('.success').css('display', 'inline-block').delay(1300).fadeOut(700)

    _file = JSON.parse(file)
    @setAudioPlayerSrc(_file.url)
    @enableHighlighting()


  enablePreview: ->
    @$('#preview-alignment').removeClass('disabled')


  enableHighlighting: ->
    @$('#begin-alignment').removeClass('disabled')


  setAudioPlayerSrc: (voiceoverUrl) ->
    @$('audio').attr('src', voiceoverUrl)


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


  #  uploadDidError: ->
  #    alert AUDIO_UPLOAD_ERROR


  # uploadDidFinish: (file) =>
  #   App.currentSelection.get('keyframe').updateContentHighlightTimes(null)
  #
  #   audioFile = JSON.parse(file)
  #   @setAudioPlayerSrc(audioFile.url)
  #   @changeUploadBtnText()
  #   @setFilenamePostUpload(audioFile.name)
  #   @disableAlignBtns(false)


  # changeUploadBtnText: (text = 'Upload') ->
  #   $uploadBtn = '#upload-audio'
  #   $($uploadBtn).text(text)


  # setFilenamePostUpload: (filename) ->
  #   $filename = '#filename'
  #   $($filename).html("#{filename} <span>uploaded</span>")


  # setAudioPlayerSrc: (url) ->
  #   $(@el).find('audio').attr('src', url)


  # currentKeyframeAudioUrl: ->
  #   "/keyframes/#{App.currentSelection.get('keyframe').get('id')}/audio"


  # appendKeyframetext: (keyframe_text) ->
  #   view = new App.Views.SortableKeyframeText(model: keyframe_text)
  #   $(@el).find('ul#sortable-keyframe-texts').append(view.render().el)


  #  initAlignAudioModalInteractions: =>
  #    @initAudioUploader()
  #    @initSorting()


  # initSorting: ->
  #   $(@el).find('ul#sortable-keyframe-texts')
  #     .sortable
  #       update:   @updateKeyframetextOrder
  #       disabled: true


  # enableSorting: ->
  #   $(@el).find('ul#sortable-keyframe-texts')
  #     .sortable "option", "disabled", false
  #   $(@el).find('li').addClass('grab')
  #   this


  # disableSorting: ->
  #   $(@el).find('ul#sortable-keyframe-texts')
  #     .sortable "option", "disabled", true
  #
  #   $(@el).find('li').removeClass("grab")


  # initAudioUploader: ->
  #   $file =        $('#audio-file')
  #   $progBar =     $('#audio-upload-progress')
  #   $bttn =        $('#upload-audio')
  #   $audioTextEl = $('#current-audio-text')
  #
  #   @audioUploader = new audioUploader($file.get(0),
  #     url:                @currentKeyframeAudioUrl()
  #     error:   (event) => @uploadDidError(event)
  #     success: (file)  => @uploadDidFinish(file)
  #   )
  #
  #   @findExistingAudio()
  #
  #   #  $('#start-manual-alignment a').live "click", =>
  #   #    @initManualAlignment()
  #
  #   $('audio').live "click", (e) ->
  #     return unless $(this).hasClass('disabled')
  #     e.preventDefault()
  #
  #   $('#reorder-text a').on "click", (e) =>
  #     el =   $(e.currentTarget)
  #     text = el.text()
  #
  #     if text is "(done sorting text)"
  #       $('#sortable-keyframe-texts li').css('border-width', '0')
  #       el.text('(reorder text)')
  #       @disableSorting()
  #     else
  #       $('#sortable-keyframe-texts li').css('border', '1px dashed black')
  #       el.text('(done sorting text)')
  #       @enableSorting()


  # findExistingAudio: =>
  #   $el =       '#upload-or-change-audio'
  #   $filename = '#filename'
  #
  #   $.getJSON @currentKeyframeAudioUrl(), (file) =>
  #     unless file.url? and file.name?
  #       $($el).find('span').show()
  #       $($el).find('span#looking-for-audio').text('No audio found.')
  #     else
  #       @audioDidExistOnLoad(file)


  # audioDidExistOnLoad: (file) ->
  #   $el = '#upload-or-change-audio'
  #   $($el).find('span').show()
  #
  #   $loading =  'span#looking-for-audio'
  #   $($loading).remove()
  #
  #   $filename = '#filename'
  #   $($filename).html("#{file.name}&nbsp;&nbsp;<span>&nbsp;&nbsp;uploaded</span>")
  #
  #   @setAudioPlayerSrc(file.url)
  #
  #   @disableAlignBtns(false)


  # disableAlignBtns: (willDisable) ->
  #   $uploadBtn =   '#upload-audio'
  #   $btns =        '#start-auto-align, #start-manual-align'
  #
  #   if willDisable
  #     $($btns).addClass('disabled')
  #   else
  #     $($btns).removeClass('disabled')
  #     $($uploadBtn).addClass('disabled')


  # updateKeyframetextOrder: =>
  #   $.post('/texts/reorder',
  #     $(@el).find('ul#sortable-keyframe-texts').sortable('serialize'),
  #     @changeSyncPlayButtonState,
  #     'json')
  #   this


  # canManuallyAlign: ->
  #   @_canManuallyAlign


  # prevElHighlighted: (el) ->
  #   el.prev().hasClass "highlighted"


  # isFirstWord: (el) ->
  #   isFirstWord = if el.parent().is('li:first-child') or el.is("span:first-child") then true else false
  #   isFirstWord


  # isMouseDown: ->
  #   @_isMouseDown


  # prevElHighlighted: (el) ->
  #   el.prev().hasClass('highlighted')


  # canHighlightEl: (el) ->
  #   isHighlightable = @prevElHighlighted(el) or @isFirstWord(el)
  #   isHighlightable


  # initCountForAlignment: (e) =>
  #   e.preventDefault()
  #
  #   $countEl = "#countdown"
  #   $($countEl).remove() if $($countEl)
  #
  #   $audioPlayer = '#sync-player audio'
  #   $('<div id="countdown"></div>').insertBefore($audioPlayer)
  #
  #   @_popcorn = Popcorn('audio')
  #   @_popcorn.on "ended", => @finishedPlaying()
  #
  #   endTime = (new Date()).getTime() + COUNTDOWN_LENGTH_IN_SECONDS * 1000
  #   $('#countdown').countdown
  #     timestamp: endTime
  #     callback:  (days, hours, minutes, seconds) =>
  #       words = $('#sortable-keyframe-texts')
  #       words.find('span').addClass('enabled')
  #
  #       if seconds is 0 and not @_countdownEnded
  #
  #         @_popcorn.play()
  #         @_popcorn.playbackRate(0.6)
  #
  #         $('audio.disabled').removeClass('disabled')
  #         $('#countdown').remove()
  #
  #         @allowManualAlignment()
  #
  #         @_canManuallyAlign = true
  #         @_countdownEnded = true


  # finishedPlaying: ->
  #   if not @_previewing
  #     $prevBtn = '#preview-alignment'
  #     $($prevBtn).
  #       removeClass('disabled').
  #       find('.icon-white').
  #       removeClass('icon-white').
  #       addClass('icon-black')
  #
  #     @disableManualAlignment()
  #   else
  #
  #     @_previewing = false
  #
  #     words = $("#sortable-keyframe-texts li span")
  #     words.  removeClass('highlighted')
  #
  #     $acceptBtn = '#accept-alignment'
  #     $($acceptBtn).removeClass('disabled')


  # disableManualAlignment: ->
  #   $keyframeTexts = '#sortable-keyframe-texts'
  #   $($keyframeTexts).find('span').removeClass('highlighted')
  #
  #   $('audio').addClass('disabled')
  #
  #   @_canManuallyAlign = false


  # playWithAlignment: ->
  #   words = $("#sortable-keyframe-texts li span")
  #   words.removeClass('highlighted')
  #
  #   unless @_initialized
  #     @_initialized = true
  #
  #     $.each words, (index, wordObj) =>
  #       words.removeClass('highlighted')
  #       $(wordObj).attr('id', 'word-' + index)
  #
  #       if $(words[index + 1]).length > 0
  #         endTime = parseFloat($(words[index + 1]).attr("data-start"))
  #       else
  #         # endTime = parseFloat($(wordObj).attr("data-start")) + 1
  #         # console.log "last el, index: ", index
  #
  #       @_popcorn.footnote
  #         start:      $(wordObj).attr("data-start")
  #         end:        endTime
  #         text:       ''
  #         target:     'word-' + index
  #         effect:     'applyclass'
  #         applyclass: 'highlighted'
  #
  #
  #   @_popcorn.play()
  #   @_popcorn.playbackRate(1.0)
  #
  #   @_previewing = true
  #

  #allowManualAlignment: =>
  #  keyframeTexts = $('#sortable-keyframe-texts')
  #  keyframeTexts.find("span").mousedown( (e) =>
  #    return false unless @canManuallyAlign()
  #
  #    @_isMouseDown = true
  #
  #    if @canHighlightEl($(e.currentTarget)) and @_countdownEnded
  #      wordStartTime = Math.round(1000 * @_popcorn.currentTime()) / 1000
  #      $(e.currentTarget)
  #        .addClass("highlighted")
  #        .attr "data-start", wordStartTime
  #    false
  #  ).mouseover( (e) =>
  #    return  unless @canManuallyAlign()
  #
  #    wordStartTime = Math.round(1000 * @_popcorn.currentTime()) / 1000
  #    if @isMouseDown() and @canHighlightEl($(e.currentTarget))
  #      $(e.currentTarget)
  #        .addClass("highlighted")
  #        .attr "data-start", wordStartTime
  #
  #  ).bind "selectstart", ->
  #    false
  #
  #  $(document).mouseup => @_isMouseDown = false

