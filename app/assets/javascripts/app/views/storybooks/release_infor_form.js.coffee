#
# Information about the content of the application.
#
class App.Views.Storybooks.ReleaseInfoForm extends Backbone.View
  template: JST['app/templates/storybooks/release_info']

  render: ->
    @$el.html @template()

    @

