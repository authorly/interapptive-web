class App.Views.AppSettings extends Backbone.View
  events:
    "submit form": "updateAttributes"

  initialize: ->
    @form = new Backbone.Form(model: App.currentStorybook(),
                              template: 'bootstrap').render()

  updateAttributes: (event) ->
    event.preventDefault()

    # Submit form with backbone-forms method
    @form.commit()
    App.currentStorybook().save()

  render: ->
    $(@el).append @form.el
    this