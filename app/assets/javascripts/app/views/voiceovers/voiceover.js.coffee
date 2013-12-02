# Allow users to create a mapping between the text in a keyframe and
# its voiceover sound. (aka aligning text to audio).
#
# It orchestrates
# * a voiceover sound selector
# * a highlighter view (instanceof `AbstractVoiceoverHighlighter`) that allows
# to create the actual highlights
# * a text reordering view
# * previewing the result
#
# RFCTR Create a Voiceover Backbone model and move model related things.
# @author dira, @date 2013-01-14
class App.Views.Voiceover extends Backbone.View
  template: JST['app/templates/voiceovers/voiceover']

  events:
    # Prevent the browser from highlighting words when dragging over them
    # (normal behavior), to use our own highlighting.
    'selectstart':                  'cancelNativeHighlighting'
    'click #preview-alignment':     'clickPreviewAlignment'
    'click #accept-alignment':      'acceptAlignment'
    'click #highlighter-type':      'switchHighlighterType'


  initialize: ->
    @keyframe = @model
    @player = null



  render: ->
    @$el.html(@template(keyframe: @keyframe))
    @_initVoiceoverSelector()
    @_initVoiceoverHighlighter('basic')
    @_toggleVoiceoverHighlighterSwitcher('basic')
    @_attachKeyframeEvents()
    @_findExistingVoiceover()
    @enableMediaPlayer()
    @


  remove: ->
    @stopVoiceover()
    @voiceoverHighlighter?.remove()
    super


  acceptAlignment: (event) ->
    unless @keyframe.hasVoiceover()
      App.trackUserAction 'Cancelled highlighting (no audio)'
      App.vent.trigger('hide:modal')
      return

    if (intervals = @voiceoverHighlighter.collectTimeIntervals()).length is 0
      App.vent.trigger('show:message', 'error', "Partial highlights are not acceptable. Please highlight entire text and then click on Accept button")

    else
      @keyframe.updateContentHighlightTimes intervals,
        # TODO replace this with a 'done' event that the parent listens to
        # 2013-05-07 @dira
        success: ->
          App.vent.trigger 'hide:modal'
          App.trackUserAction 'Completed highlighting'


  clickPreviewAlignment: (event) =>
    return unless @keyframe.hasText()
    return unless @keyframe.hasVoiceover()
    @previewOrStopPreview(event)
    @voiceoverHighlighter.setHighlightTimesForWordEls()

    @_previewingAlignment = true


  previewOrStopPreview: (event) ->
    $el = @$(event.currentTarget)
    if $el.find('i').hasClass('icon-play')
      @player.play()
      @player.playbackRate(1.0)
      @voiceoverHighlighter.disableBeginAlignment()
      @_showStopButton($el)
    else
      @voiceoverHighlighter.stopAlignment()
      @_showPreviewButton($el)


  cancelNativeHighlighting: ->
    false


  setExistingVoiceover: (voiceover) ->
    @setAudioPlayerSrc(voiceover)
    @voiceoverHighlighter.enableBeginAlignment()


  noVoiceoverFound: ->
    @setAudioPlayerSrc()
    @disablePreview()
    @voiceoverHighlighter.disableBeginAlignment()


  enableMediaPlayer: =>
    if App.Lib.BrowserHelper.canPlayVorbis()
      @player = Popcorn('#media-player-ogg')
    else
      @player = Popcorn('#media-player-mp3')
    @voiceoverHighlighter.player = @player

    @player.on 'ended', =>

      if @_previewingAlignment
        @previewingEnded()
      else
        @enableAcceptAlignment()
        @enablePreview()
      @voiceoverHighlighter.resetHighlightControls()


  previewingEnded: ->
    @_previewingAlignment = false
    @enableAcceptAlignment()
    @_showPreviewButton(@$('#preview-alignment'))


  enablePreview: ->
    @$('#preview-alignment').removeClass('disabled')


  disablePreview: ->
    @$('#preview-alignment').addClass('disabled')


  enableAcceptAlignment: ->
    @$('#accept-alignment').removeClass('disabled')


  disableAcceptAlignment: ->
    @$('#accept-alignment').addClass('disabled')


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
    @player.pause()


  switchHighlighterType: ->
    highlighter_type = $('a#highlighter-type').data('type')
    @_initVoiceoverHighlighter(highlighter_type)
    @_toggleVoiceoverHighlighterSwitcher(highlighter_type)


  _toggleVoiceoverHighlighterSwitcher: (highlighter_type) ->
    $element = @$('a#highlighter-type')
    if highlighter_type is 'basic'
      $element.text('Advance Aligner')
      $element.data('type', 'advance')
    else
      $element.text('Basic Aligner')
      $element.data('type', 'basic')


  _findExistingVoiceover: ->
    if (voiceover = @keyframe.voiceover())?
      @setExistingVoiceover(voiceover)
      @voiceoverHighlighter.findExistingHighlightTimes()
    else
      @noVoiceoverFound()


  _initVoiceoverHighlighter: (control_type) ->
    @voiceoverHighlighter?.remove()
    klass = App.Lib.StringHelper.capitalize(control_type)
    @voiceoverHighlighter = new App.Views[klass + 'VoiceoverHighlighter']
      model: @keyframe
      id: '#voiceover-highlighter'
    @voiceoverHighlighter.player = @player

    @_attachVoiceoverHighlighterEvents()
    App.trackUserAction(klass + ' aligner clicked')
    @$('#voiceover-selector-container').after(@voiceoverHighlighter.render().el)
    @_findExistingVoiceover()


  _initVoiceoverSelector: ->
    @voiceoverSelector = new App.Views.VoiceoverSelector
      keyframe: @keyframe
      collection: @keyframe.scene.storybook.sounds
      el: @$('#voiceover-selector-container')

    @voiceoverSelector.render()


  _attachVoiceoverHighlighterEvents: ->
    @listenTo(@voiceoverHighlighter, 'hide:voiceoverControls', @hideControls)
    @listenTo(@voiceoverHighlighter, 'show:voiceoverControls', @showControls)

    @listenTo(@voiceoverHighlighter, 'enable:voiceoverPreview', @enablePreview)
    @listenTo(@voiceoverHighlighter, 'disable:voiceoverPreview', @disablePreview)

    @listenTo(@voiceoverHighlighter, 'enable:acceptVoiceoverAlignment', @enableAcceptAlignment)
    @listenTo(@voiceoverHighlighter, 'disable:acceptVoiceoverAlignment', @disableAcceptAlignment)

    @listenTo(@voiceoverHighlighter, 'enable:voiceoverMediaPlayer', @enableMediaPlayer)


  _attachKeyframeEvents: ->
    @listenTo @keyframe, 'change:voiceover_id', @_findExistingVoiceover


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
