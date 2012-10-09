class App.Views.AbstractFormView extends Backbone.View
  events: ->
    "click .btn-submit": "updateAttributes"
    "click .btn-danger": "delete"
    "click .btn-submit-cancel": "cancel"

  initialize: ->
    @form = new Backbone.Form(@formOptions()).render()

  formOptions: ->
    model: @model

  deleteMessage: ->
    '\nYou are about to delete this. This cannot be undone.\n\n\n' +
    'Are you sure you wish to continue?'

  render: ->
    $(@el).append @form.el
    this

  updateAttributes: (e) ->
    console.log "Clicked Save."
    e.preventDefault()
    @form.commit()

    @model.save {},
      success: ->
        App.modalWithView().hide()

  delete: (e) ->
    e.preventDefault()

    if confirm(@deleteMessage()) then @form.model.destroy() and document.location.reload true

  cancel: (e) ->
    e.preventDefault()
    @resetValues()
    App.modalWithView().hide()

  # Defines jquery actions to reset the form to its default 
  # (since we use M/V bindings we have to reset it or 
  resetValues: ->
    # e.g.
    # $('#c9_title').val App.currentStorybook().get('title')
