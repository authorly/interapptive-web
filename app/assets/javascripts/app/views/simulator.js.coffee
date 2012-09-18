class App.Views.Simulator extends Backbone.View
  template: JST["app/templates/simulator"]

  className: 'simulator'

  events: {}

  initialize: (options={}) ->
    @json = options.json

  render: =>
    @$el.html(@template(json: @json))

    this
