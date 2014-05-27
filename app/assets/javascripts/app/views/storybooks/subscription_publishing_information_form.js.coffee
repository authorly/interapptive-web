class App.Views.SubscriptionPublishingInformationForm extends App.Views.AbstractFormView

  render: ->
    super

    @$('form').removeClass('form-horizontal').
      find('.btn-submit').text('Save')

    @
