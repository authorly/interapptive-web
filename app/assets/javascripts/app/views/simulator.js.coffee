class App.Views.Simulator extends Backbone.View
  template: JST['app/templates/simulator']

  className: 'simulator'

  events: {}


  initialize: (options={}) ->
    @options = options


  render: =>
    @$el.html @template(json: @options.json, fonts: @options.fonts, url: @options.url + "?timestamp=" + @timestamp())

    @


  timestamp: ->
    (Math.random() + "").substr(-10)
