class App.Views.AboutView extends Backbone.View
  template: JST["app/templates/about"]

  render: ->
    $(@el).html(@template())
    this
