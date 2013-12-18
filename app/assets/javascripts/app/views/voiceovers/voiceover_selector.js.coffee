class App.Views.VoiceoverSelector extends Backbone.View
  template: JST['app/templates/voiceovers/selector']

  events:
    'change #voiceover-selector': 'voiceoverChanged'

  render: ->
    @$el.html(@template(sounds: @collection))
    @_selectOption()
    @


  voiceoverChanged: (event) ->
    $selectedVoiceover = $(event.currentTarget)
    if $selectedVoiceover.val() is 'none'
      @options.keyframe.save
        voiceover_id: null
    else
      App.trackUserAction 'Selected voiceover file'
      @options.keyframe.save
        voiceover_id: $selectedVoiceover.val()


  _selectOption: ->
    @$("option[value='#{@options.keyframe.get('voiceover_id')}']").attr('selected', 'selected')
