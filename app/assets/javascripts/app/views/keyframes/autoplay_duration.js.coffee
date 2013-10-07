class App.Views.AutoplayDuration extends Backbone.View
  template: JST['app/templates/keyframes/autoplay_duration']

  events:
    'click .show-custom-duration':    '_showCustomDurationClicked'
    'click .custom-duration .save':   '_setCustomDurationClicked'
    'click .custom-duration .cancel': '_cancelCustomDurationClicked'
    'click .revert-to-default':       '_revertToDefaultClicked'


  initialize: ->
    @listenTo @model, 'change:voiceover_id', @render
    @listenTo @model, 'invalid:autoplay_duration', @_invalidAutoplayDurationEntered


  remove: ->
    @stopListening()


  render: ->
    @$el.html @template(
      duration: @model.autoplayDuration()
      source:   @model.autoplaySource()
    )

    @


  _showCustomDurationClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()

    @$('.current-value').hide()
    @$('.custom-duration').show().find('input').focus()


  _setCustomDurationClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()

    @model.set
      autoplay_duration: parseInt(@$('.custom-duration input').val()) || 0
    @render()


  _showCurrentValue: ->
    @$('.current-value').show()
    @$('.custom-duration').hide()


  _cancelCustomDurationClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()

    @$('.custom-duration input').val @model.autoplayDuration()
    @_showCurrentValue()


  _revertToDefaultClicked: (event) ->
    event.stopPropagation()
    event.preventDefault()

    @model.set
      autoplay_duration: null
    @render()


  _invalidAutoplayDurationEntered: (duration) ->
    alert "Please enter a positive, one-decimal number for animation duration (e.g. 0, 1, 4.5). #{duration} is not allowed"

