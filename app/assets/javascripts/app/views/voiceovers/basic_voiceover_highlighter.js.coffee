#= require ./abstract_voiceover_highlighter

# This view enables users to drag/click on words of the keyframe text.
# As they click/drag over each word in sync with the associated audio,
# we accumulate an array of time intervals. Intervals are then used for
# highlighting word-by-word.

class App.Views.BasicVoiceoverHighlighter extends App.Views.AbstractVoiceoverHighlighter
  template: JST['app/templates/voiceovers/basic_voiceover_highlighter']

  events:
    'click .begin':       'beginClicked'
    'click .cancel':      'cancelClicked'
    'mousedown .word':    'mouseDownOnWord'
    'mouseover .word':    'mouseOverWord'
    'click .reorder .start a': 'reorderClicked'
    'click .reorder .done  a':  'finishReorderClicked'

  COUNTDOWN_SECONDS: 5

  initialize: ->
    super
    @playbackRate = 0.5
    @_aligning = false
    @_mouseDown = false

    $(document).mouseup @onMouseUp


  render: ->
    super
    @words = @$('.words')
    @_initPlaybackRate()
    @_initSorting()
    @


  remove: ->
    @playbackRateView.remove()
    $(document).unbind 'mouseup', @onMouseUp
    super


  onMouseUp: =>
    @_mouseDown = false


  initializeWordHighlights: ->
    $.each @$('.word'), (index, word) =>
      @$(word).data('start', "#{@intervals[index]}")


  _clearWordHighlights: ->
    $.each @$('.word'), (index, word) =>
      @$(word).removeData('start')


  beginClicked: (event) =>
    event.preventDefault()

    return unless @keyframe.hasText()
    return unless @keyframe.hasVoiceover()
    return if @$('.begin.disabled').length > 0

    App.trackUserAction 'Began highlighting'

    @$('.begin').addClass 'disabled'
    @$('.reorder').css 'visibility', 'hidden'
    @$('.playback-rate-container').show()
    @removeWordHighlights()
    @_clearWordHighlights()
    @startCountdown()

    @trigger 'start'


  cancelClicked: (event) =>
    @_aligning = false
    @player.pause(@player.duration())
    @removeWordHighlights()
    @$('.begin').show()
    @$('.cancel').hide()
    @$('.reorder').css 'visibility', 'visible'
    @$('.playback-rate-container').hide()

    @trigger 'cancel'


  mouseOverWord: (event) =>
    return false unless @_mouseDown
    @mouseDownOnWord(event)
    true


  mouseDownOnWord: (event) =>
    return false unless @_aligning
    @_mouseDown = true

    $wordEl = @$(event.currentTarget)
    if @canHighlightEl($wordEl)
      $wordEl.addClass('highlighted').data('start', @_playerCurrentTimeInSeconds())
    false


  startCountdown: ->
    @words.find('.word').addClass('disabled')

    @initCountdown()


  initCountdown: ->
    endTime = (new Date()).getTime() + @COUNTDOWN_SECONDS * 1000
    @$('.countdown').show().jcountdown
      timestamp: endTime
      callback: (days, hours, minutes, seconds) =>
        if seconds is 0
          @$('.countdown *').remove()
          @startAligning()


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
    changed = false
    @words.find('li').each (index, element) =>
      element = $(element)

      if (id = element.data('id'))? && (text = @keyframe.widgets.get(id))?
        zOrder = zero + index
        changed = true if text.get('z_order') != zOrder
        text.set {z_order: zOrder}, silent: true

    if changed
      @initializeWordHighlights()
      @keyframe.widgets.trigger('change')


  startAligning: ->
    @_aligning = true
    @$('.begin').removeClass('disabled').hide()
    @$('.cancel').show()

    @words.find('.word').removeClass('disabled')

    @player.play()
    @player.playbackRate(@playbackRate)


  playEnded: ->
    return unless @_aligning

    @$('.begin').show()
    @$('.cancel').hide()
    @$('.reorder').css 'visibility', 'visible'
    @$('.playback-rate-container').hide()
    @removeWordHighlights()

    @trigger 'done'



  reorderClicked: ->
    @$('.highlight').css 'visibility', 'hidden'
    @words.sortable 'option', 'disabled', false
    @words.find('li').addClass('grab')
    @$('.reorder .start').hide()
    @$('.reorder .done').show()

    @trigger 'start:reorder'


  finishReorderClicked: ->
    @updateOrder()

    @$('.highlight').css 'visibility', 'visible'
    @words.sortable 'option', 'disabled', true
    @words.find('li').removeClass('grab')
    @$('.reorder .start').show()
    @$('.reorder .done').hide()

    @trigger 'finished:reorder'


  _playerCurrentTimeInSeconds: ->
    Math.round(1000 * @player.currentTime()) / 1000


  _initSorting: ->
    @words.sortable
      disabled: true


  _initPlaybackRate: ->
    @playbackRateView = new App.Views.VoiceoverPlaybackRateSlider
      playbackRate: @playbackRate
      el: @$('.playback-rate-container')
    @_attachPlaybackSliderEvents()

    @playbackRateView.render()


  _attachPlaybackSliderEvents: ->
    @listenTo @playbackRateView, 'change', @_playbackRateChanged


  _playbackRateChanged: (value) ->
    @playbackRate = value
    @player.playbackRate(@playbackRate)


  disableHighlightControls: ->
    $('.reorder .highlight').css 'visibility', 'hidden'


  enableHighlightControls: ->
    $('.reorder .highlight').css 'visibility', 'visible'
