class App.Views.AppSettings extends Backbone.View
  events:
    "click .btn-submit": "updateAttributes"
    "click .btn-danger": "delete"
    "click .btn-submit-cancel": "cancel"

  initialize: ->
    @form = new Backbone.Form(model: App.currentStorybook(),
                              template: 'bootstrap').render()

  render: ->
    $(@el).append @form.el
    this

  updateAttributes: (e) ->
    event.preventDefault()

    @form.commit()

    App.currentStorybook().save {},
      success: ->
        App.modalWithView().hide()

  delete: (e) ->
    e.preventDefault()

    message  =
      '\nYou are about to delete this storybook and all of it\'s scenes, keyframes, images, etc.\n\n\n' +
      'This cannot be undone.\n\n\n' +
      'Are you sure you want to continue?\n'

    if confirm(message) then @form.model.destroy() and document.location.reload true

  cancel: (e) ->
    e.preventDefault()
    @resetValues()
    App.modalWithView().hide()

  resetValues: ->
    $('#c9_title').val App.currentStorybook().get('title')
    $('#c9_author').val App.currentStorybook().get('author')
    $('#c9_price').val App.currentStorybook().get('price')
    $('#c9_description').val App.currentStorybook().get('description')

    $('#c9_android_or_ios button').removeClass('active')
    $('#c9_android_or_ios button:nth-child(2)').addClass('active')

    $('#c9_record_enabled button').removeClass('active')
    $('#c9_record_enabled button:nth-child(1)').addClass('active')