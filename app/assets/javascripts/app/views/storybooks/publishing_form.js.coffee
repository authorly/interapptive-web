class App.Views.PublishingForm extends App.Views.AbstractFormView

  initialize: ->
    super
    @listenTo @, 'success', ->
      # XXX replace with proper message
      message = "Your application is going to be published. You will receive an email as soon as it is available in each app store."
      App.vent.trigger 'show:message', 'success', message
      @model.storybook.fetch()


  render: ->
    super

    @$('form').removeClass('form-horizontal').
      find('.btn-submit').text('Publish app')

    @


  submit: (event) ->
    # TODO add proper message here
    if confirm("Once an app is submitted, the publishing information (data and screenshots) can't be changed (for now)")
      super
    else
      event.preventDefault()
