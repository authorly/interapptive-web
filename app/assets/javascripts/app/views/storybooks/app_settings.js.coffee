class App.Views.AppSettings extends Backbone.View
  events:
    "submit form": "updateAttributes"


  initialize: ->
    @appSettingsForm = new Backbone.Form(model: App.currentStorybook(),
                                         template: 'bootstrap').render()

  # Updates settings on model
  updateAttributes: (ev) ->
    # Stop propogation
    ev.preventDefault()

    # Submit form with backbone-forms method
    @appSettingsForm.commit()
    App.currentStorybook().save()

  render: ->
    # Render backbone-forms generated HTML form
    $("#storybook-settings").html(@appSettingsForm.el)