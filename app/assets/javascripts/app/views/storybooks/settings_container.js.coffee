#
# Application-wide settings for storybook.
#
class App.Views.SettingsContainer extends Backbone.View
  template: JST['app/templates/storybooks/settings_container']

  render: ->
    @$el.html @template()

    view = new App.Views.Storybooks.GeneralSettingsForm
      model: @model
    @$('.modal-body').html(view.render().el)

    @
