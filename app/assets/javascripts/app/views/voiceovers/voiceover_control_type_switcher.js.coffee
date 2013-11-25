class App.Views.VoiceoverControlTypeSwitcher extends Backbone.View

  initialize: ->
    @highlight_type = 'advance'

  render: ->
    @$el.text('Advance Controls')
    @
