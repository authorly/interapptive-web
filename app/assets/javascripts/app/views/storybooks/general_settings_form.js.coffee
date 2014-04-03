App.Views.Storybooks ?= {}

class App.Views.Storybooks.GeneralSettingsForm extends App.Views.AbstractFormView

  initialize: ->
    super
    @listenTo @, 'success', ->
      App.trackUserAction 'Saved app settings (general)'


  render: ->
    super
    @$('fieldset').prepend("<div class='control-group'>
      <label class='control-label'>Approximate Application Size</label>
      <div class='controls'>
        <div>iOS: #{App.Lib.NumberHelper.numberToHumanSize(@model.compiledApplicationSize())}</div>
        <div>Android: #{App.Lib.NumberHelper.numberToHumanSize(@model.compiledApplicationSize('android'))}</div>
      </div>
    </div>")
    @

  formOptions: =>
    model: @model
