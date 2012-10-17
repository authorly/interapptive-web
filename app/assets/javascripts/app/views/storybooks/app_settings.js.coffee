class App.Views.AppSettings extends App.Views.AbstractFormView 
  events: ->
    _.extend({}, super, {})

  formOptions: =>
    model: @getModel()

  getModel: ->
    @model = App.currentStorybook()
    
  initialize: ->
    super

  deleteMessage: ->
    '\nYou are about to delete this storybook and all of it\'s scenes, keyframes, images, etc.\n\n\n' +
    'This cannot be undone.\n\n\n' +
    'Are you sure you want to continue?\n'
