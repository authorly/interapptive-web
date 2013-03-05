DELETE_MSG =
  '\nYou are about to delete this. This cannot be undone.\n\n\n' +
  'Are you sure you wish to continue?'


class App.Views.AbstractFormView extends Backbone.View

  events: ->
    'click .btn-submit-cancel' : 'cancel'
    'click .btn-submit'        : 'updateAttributes'
    'click .btn-danger'        : 'delete'


  initialize: ->
    @form = new Backbone.Form(@formOptions()).render()


  formOptions: ->
    model: @model


  deleteMessage: ->
    DELETE_MSG

  render: ->
    @$el.append @form.el
    @


  updateAttributes: (event) ->
    event.preventDefault()

    @form.commit()
    @model.save {},
      success: ->
        App.modalWithView().hide()


  delete: (event) ->
    event.preventDefault()

    if confirm DELETE_MSG
      @form.model.destroy() and document.location.reload true


  cancel: (event) ->
    event.preventDefault()
    @resetValues()
    App.vent.trigger 'hide:modal'


  # Defines jquery actions to reset the form to its default 
  # (since we use M/V bindings we have to reset it or 
  resetValues: ->
    # e.g.
    # $('#c9_title').val App.currentStorybook().get('title')
