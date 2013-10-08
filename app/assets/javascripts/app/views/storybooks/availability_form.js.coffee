#
# Availability settings for the application.
#
class App.Views.Storybooks.AvailabilityForm extends Backbone.View
  template: JST['app/templates/storybooks/availability']

  render: ->
    @$el.html @template()

    @
