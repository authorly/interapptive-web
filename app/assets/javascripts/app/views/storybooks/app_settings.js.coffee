class App.Views.AppSettings extends Backbone.View
  events:
    "submit form": "updateAttributes"

  initialize: ->
    @form = new Backbone.Form(model: App.currentStorybook(),
                              template: 'bootstrap').render()

  render: ->
    $(@el).append @form.el
    this

  updateAttributes: (event) ->
    event.preventDefault()
    errors = @form.commit()
    console.log "~_~_~_~_~_~_~_~_~_~_~_~_~_~"
    console.log errors
    console.log "~_~_~_~_~_~_~_~_~_~_~_~_~_~"


