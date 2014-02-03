App.Views.Storybooks ?= {}

class App.Views.Storybooks.GeneralSettingsForm extends App.Views.AbstractFormView

  initialize: ->
    super
    @listenTo @, 'success', ->
      App.trackUserAction 'Saved app settings (general)'


  formOptions: =>
    model: @model

