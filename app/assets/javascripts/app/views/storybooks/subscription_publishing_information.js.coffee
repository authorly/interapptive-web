#
# Add data for publishing on the subscription platform
#
class App.Views.SubscriptionPublishingInformation extends Backbone.View
  template: JST['app/templates/storybooks/subscription_publishing']

  render: ->
    @$el.html @template()

    @view = new App.Views.SubscriptionPublishingInformationForm
      model: @model.subscription_publish_information

    @$('.modal-body').html('').append @view.render().el
    @


  remove: ->
    @view.remove()
    super

