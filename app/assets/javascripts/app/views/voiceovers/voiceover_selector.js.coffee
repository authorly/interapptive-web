class App.Views.VoiceoverSelector extends Backbone.View
  template: JST['app/templates/voiceovers/selector']

  events:
    'change #voiceover-selector': 'voiceoverChanged'


  initialize: ->
    @listenTo @collection, 'change:transcode_complete', @render


  render: ->
    @$el.html @template(sounds: @collection)
    @_selectOption()
    @


  voiceoverChanged: (event) ->
    $selectedVoiceover = $(event.currentTarget)
    id = if $selectedVoiceover.val() is 'none'
      null
    else
      Number($selectedVoiceover.val())

    @options.keyframe.save {
      voiceover_id: id
    }, patch: true


  _selectOption: ->
    @$("option[value='#{@options.keyframe.get('voiceover_id')}']").attr('selected', 'selected')
