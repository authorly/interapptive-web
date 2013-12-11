class App.Views.AbstractFormView extends Backbone.View
  DELETE_MSG =
    '\nYou are about to delete this. This cannot be undone.\n\n\n' +
    'Are you sure you wish to continue?'


  events: ->
    'click .btn-submit':        'submit'
    'submit form':              'submit'
    'click .btn-submit-cancel': 'cancel'


  initialize: ->
    @listenTo @model, 'error', @onError


  formOptions: ->
    model: @model


  deleteMessage: ->
    DELETE_MSG


  render: ->
    @form = new Backbone.Form(@formOptions()).render()
    @$el.append @form.el
    @


  remove: ->
    @form.remove()
    super


  submit: (event) ->
    event.preventDefault()

    @$('.help-error').val('')
    errors = @form.commit()
    if errors?
      @goToFirstError()
      return

    @model.save {},
      success: =>
        @trigger 'success'
        App.vent.trigger 'hide:modal'


  onError: (model, xhr) ->
    errors = jQuery.parseJSON(xhr.responseText)
    form = @form.$el

    for field of errors
      id = '#' + model.cid + '_' + field
      control_group = $(id).parents('.control-group')

      if control_group.length > 0
        control_group.addClass('error').
          find('.help-error').html(errors[field].join(', '))

    @goToFirstError()


  goToFirstError: ->
    @$('.error')[0].scrollIntoView(true)


  delete: (event) ->
    event.preventDefault()

    if confirm @deleteMessage()
      @form.model.destroy() and document.location.reload true


  cancel: (event) ->
    event.preventDefault()
    App.vent.trigger 'hide:modal'

