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
class App.Views.Voiceover extends Backbone.View
  template: JST['app/templates/voiceovers/voiceover']

  events:
    # Prevent the browser from highlighting words when dragging over them
    # (normal behavior), to use our own highlighting.
    'selectstart':              'cancelNativeHighlighting'
    'click .controls .preview': 'previewClicked'
    'click .controls .accept':  'acceptClicked'
    # 'click #highlighter-type':      'switchHighlighterType'


  initialize: ->
    @keyframe = @model
    @player = null

    @listenTo @keyframe, 'change:voiceover_id', @_voiceoverChanged


  render: ->
    @$el.html @template(keyframe: @keyframe)

    @_initVoiceoverSelector()

    if @keyframe.hasText()
      @$('.highlighter-container .not-found').hide()
      @_initVoiceoverHighlighter('basic')
      # @_toggleVoiceoverHighlighterSwitcher('basic')
      @_voiceoverChanged()

      # it needs this view to be added to the DOM
      window.setTimeout @_initPlayer, 0
    else
      @$('.highlighter-container').find('.selector, .highlighter').hide()

    @


  remove: ->
    @player.pause()
    @highlighter.remove()
    super


  acceptClicked: (event) ->
    intervals = @highlighter.collectTimeIntervals()
    if intervals.length is 0
      App.vent.trigger('show:message', 'error', "Partial highlights are not acceptable. Please highlight entire text and then click on Accept button")
    else
      App.vent.trigger 'hide:modal'
      App.trackUserAction 'Completed highlighting'
      @keyframe.save {
        content_highlight_times: intervals
      }, patch: true


  # previewClicked: (event) =>
    # return unless @keyframe.hasText()
    # return unless @keyframe.hasVoiceover()
    # @previewOrStopPreview(event)
    # @highlighter.setHighlightTimesForWordEls()

    # @_previewingAlignment = true


  # previewOrStopPreview: (event) ->
    # $el = @$(event.currentTarget)
    # if $el.find('i').hasClass('icon-play')
      # @player.play()
      # @player.playbackRate(1.0)
      # @highlighter.disableBeginAlignment()
      # @_showStopButton($el)
    # else
      # @highlighter.stopAlignment()
      # @_showPreviewButton($el)


  # cancelNativeHighlighting: ->
    # false




  _initPlayer: =>
    id = if App.Lib.BrowserHelper.canPlayVorbis()
      '#voiceover-ogg'
    else
      '#voiceover-mp3'
    @player = Popcorn(id)

    @highlighter.player = @player

    @player.on 'ended', =>
      @highlighter.playEnded()
      console.log 'end play'
      # if @_previewingAlignment
        # @previewingEnded()


  # previewingEnded: ->
    # @_previewingAlignment = false
    # @enableAcceptAlignment()
    # @_showPreviewButton(@$('#preview-alignment'))


  # enablePreview: ->
    # @$('#preview-alignment').removeClass('disabled')


  # disablePreview: ->
    # @$('#preview-alignment').addClass('disabled')


  # enableAcceptAlignment: ->
    # @$('.controls .accept').removeClass('disabled')


  # disableAcceptAlignment: ->
    # @$('#accept-alignment').addClass('disabled')


  setAudioPlayerSrc: (sound=null) ->
    if sound?
      @$('#voiceover-mp3').attr('src', arguments[0].get('mp3url'))
      @$('#voiceover-ogg').attr('src', arguments[0].get('oggurl'))
    else
      @$('audio').attr('src', '')


  # showControls: ->
    # @$('#controls').css('visibility', 'visible')


  # hideControls: ->
    # @$('#controls').css('visibility', 'hidden')


  # switchHighlighterType: ->
    # highlighter_type = $('a#highlighter-type').data('type')
    # @_initVoiceoverHighlighter(highlighter_type)
    # @_toggleVoiceoverHighlighterSwitcher(highlighter_type)


  # _toggleVoiceoverHighlighterSwitcher: (highlighter_type) ->
    # $element = @$('a#highlighter-type')
    # if highlighter_type is 'basic'
      # $element.text('Advance Aligner')
      # $element.data('type', 'advance')
    # else
      # $element.text('Basic Aligner')
      # $element.data('type', 'basic')


  _initVoiceoverHighlighter: (control_type) ->
    # @highlighter?.remove()
    # TODO stop listening to the events

    App.trackUserAction(klass + ' aligner clicked')

    klass = App.Lib.StringHelper.capitalize(control_type)
    @highlighter = new App.Views[klass + 'VoiceoverHighlighter']
      model: @keyframe
      el: @$('.highlighter-container .highlighter')
      player: @player
    @highlighter.render()

    voiceover = @$('.voiceover-container')
    controls = @$('.highlighter-container .selector .alternative, .preview, .accept')
    @listenTo @highlighter, 'start', ->
      voiceover.css 'visibility', 'hidden'
      controls.css 'visibility', 'hidden'
    @listenTo @highlighter, 'cancel done', ->
      voiceover.css 'visibility', 'visible'
      controls.css 'visibility', 'visible'
      @$('.preview').removeClass 'disabled'

    @listenTo @highlighter, 'start:reorder', ->
      controls.css 'visibility', 'hidden'
    @listenTo @highlighter, 'finished:reorder', ->
      controls.css 'visibility', 'visible'


  _initVoiceoverSelector: ->
    @voiceoverSelector = new App.Views.VoiceoverSelector
      keyframe: @keyframe
      collection: @keyframe.scene.storybook.sounds
      el: @$('.voiceover-container .selector')

    @voiceoverSelector.render()


  # _attachVoiceoverHighlighterEvents: ->
    # @listenTo(@highlighter, 'hide:voiceoverControls', @hideControls)
    # @listenTo(@highlighter, 'show:voiceoverControls', @showControls)

    # @listenTo(@highlighter, 'enable:voiceoverPreview', @enablePreview)
    # @listenTo(@highlighter, 'disable:voiceoverPreview', @disablePreview)

    # @listenTo(@highlighter, 'enable:acceptVoiceoverAlignment', @enableAcceptAlignment)
    # @listenTo(@highlighter, 'disable:acceptVoiceoverAlignment', @disableAcceptAlignment)

    # @listenTo(@highlighter, 'enable:voiceoverMediaPlayer', @enableMediaPlayer)



  _voiceoverChanged: ->
    controls = @$('.highlighter-container, .highlighter-container, .preview')
    warning = @$('.voiceover-container .not-found')
    if (voiceover = @keyframe.voiceover())?
      controls.show()
      warning.hide()

      @setAudioPlayerSrc(voiceover)
    else
      controls.hide()
      warning.show()


  # _showStopButton: ($button) ->
    # $button.find('span')
      # .text('Stop')
      # .parent().find('i')
      # .removeClass('icon-play')
      # .addClass('icon-stop')


  # _showPreviewButton: ($button) ->
    # $button.find('span')
      # .text('Preview')
      # .parent().find('i')
      # .removeClass('icon-stop')
      # .addClass('icon-play')
