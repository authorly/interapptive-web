class App.Views.ActionFormForm extends Backbone.View

  initialize: =>
    @action             = @options.action
    @parent             = @options.parent

  render: =>
    @form = new Backbone.Form(model: @action).render()
    @form.setValue(@action.fieldValues)
    $(@el).html(@form.el)
    this
