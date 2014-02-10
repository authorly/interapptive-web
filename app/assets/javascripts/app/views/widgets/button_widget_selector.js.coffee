class App.Views.ButtonWidgetImagesSelector extends Backbone.View
  events: ->
    'click .btn-submit':        'submit'
    'submit form':              'submit'
    'click .btn-submit-cancel': 'cancel'


  initialize: ->
    @formattedWidgetName = App.Lib.StringHelper.decapitalize(@model.displayName())


  render: ->
    App.trackUserAction "Opened #{@formattedWidgetName} image selector"

    @form = @_initializeForm()
    @$el.append @form.el

    @


  submit: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @form.commit()
    App.trackUserAction "Saved #{@formattedWidgetName} button"
    App.vent.trigger 'hide:modal'


  cancel: (event) ->
    event.preventDefault()
    event.stopPropagation()
    App.vent.trigger 'hide:modal'


  _initializeForm: ->
    formOptions =
      model: @model
      schema:
        image_id:
          type: 'Image'
          title: 'The main image:'
          fieldClass: 'imageEditor'
          default: @model.defaultImage()
        selected_image_id:
          type: 'Image'
          title: 'The image to show when the button is pressed:'
          fieldClass: 'imageEditor'
          default: @model.defaultImage()
    form = new Backbone.Form(formOptions).render()
    form.$el.removeClass('form-horizontal')
    form
