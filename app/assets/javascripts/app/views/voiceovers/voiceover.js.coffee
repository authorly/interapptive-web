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
    'click .preview .start':   'startPreviewClicked'
    'click .preview .stop':    'stopPreviewClicked'
    'click .controls .accept': 'acceptClicked'
    'click .highlighter-container .selector .alternative': 'alternativeHighlighterClicked'


  initialize: ->
    @keyframe = @model
    @voiceover = new App.Models.Voiceover(keyframe: @model)
    @player = null
    @_previewFootnoteIds = []

    @listenTo @keyframe, 'change:voiceover_id', @_voiceoverChanged


  render: ->
    @$el.html @template(keyframe: @keyframe)

    @_initVoiceoverSelector()
    @_voiceoverChanged()

    if @keyframe.hasText()
      @$('.highlighter-container .not-found').hide()
      @_initVoiceoverHighlighter('basic')
    else
      @$('.highlighter-container').find('.selector, .highlighter').hide()

    # it needs this view to be added to the DOM
    window.setTimeout @_initPlayer, 0

    @


  remove: ->
    @player?.pause()
    @highlighter?.remove()
    super


  acceptClicked: (event) ->
    @highlighter.cacheHighlightTimes()
    if !@voiceover.get('valid')
      App.vent.trigger('show:message', 'error', "Partial highlights are not acceptable. Please highlight entire text and then click on Accept button")
    else
      App.vent.trigger 'hide:modal'
      App.trackUserAction 'Completed highlighting'
      @keyframe.save {
        content_highlight_times: _.clone(@voiceover.get('times'))
      }, patch: true


  startPreviewClicked: (event) =>
    return if @$('.preview.start.disabled').length > 0

    return unless @keyframe.hasVoiceover()

    @$('.preview .start').hide()
    @$('.preview .stop').show()

    @player.playbackRate(1.0)
    @player.play()

    @_cleanupPreviewPlayerFootnotes()
    @_previewFootnoteIds = @highlighter?.preparePreview() || []
    @$('.highlighter-container .selector .alternative').hide()

    @_previewingAlignment = true

    App.trackUserAction 'Previewed highlighting'


  stopPreviewClicked: (event) =>
    @player.pause @player.duration()
    @enableStartPreview()


  enableStartPreview: ->
    @$('.preview .start').show()
    @$('.preview .stop').hide()
    @_cleanupPreviewPlayerFootnotes()
    @highlighter?.cleanupPreview()
    @$('.highlighter-container .selector .alternative').show()


  _cleanupPreviewPlayerFootnotes: ->
    for eventId in @_previewFootnoteIds
      @player.removeTrackEvent eventId

    @_previewFootnoteIds = []


  _initPlayer: =>
    id = if App.Lib.BrowserHelper.canPlayVorbis()
      '#voiceover-ogg'
    else
      '#voiceover-mp3'
    @player = Popcorn(id)

    @highlighter?.player = @player

    @player.on 'ended', =>
      @highlighter?.playEnded()

      if @_previewingAlignment
        @_previewingAlignment = false
        @enableStartPreview()
      else
        @highlighter?.cacheHighlightTimes()


  setAudioPlayerSrc: (sound=null) ->
    if sound?
      @$('#voiceover-mp3').attr('src', arguments[0].get('mp3url'))
      @$('#voiceover-ogg').attr('src', arguments[0].get('oggurl'))
    else
      @$('audio').attr('src', '')


  alternativeHighlighterClicked: (event) ->
    event.preventDefault()
    event.stopPropagation()

    el = @$(event.currentTarget)
    selected = el.closest('.option').hide().siblings().show()
    @_initVoiceoverHighlighter selected.data('type')



  _initVoiceoverHighlighter: (control_type) ->
    if @highlighter?
      @stopListening @highlighter
      @highlighter.remove()

    klass = App.Lib.StringHelper.capitalize(control_type)
    App.trackUserAction(klass + ' aligner clicked')


    @highlighter = new App.Views[klass + 'VoiceoverHighlighter']
      model: @voiceover
      el: $('<div/>').appendTo(@$('.highlighter-container .highlighter'))
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

