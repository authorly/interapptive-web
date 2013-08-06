App.Views.Storybooks ?= {}

class App.Views.Storybooks.GeneralSettingsForm extends App.Views.AbstractFormView

  formOptions: =>
    model: @model


  deleteMessage: ->
    '\nYou are about to delete this storybook and all of it\'s scenes, keyframes, images, etc.\n\n\n' +
    'This cannot be undone.\n\n\n' +
    'Are you sure you want to continue?\n'
