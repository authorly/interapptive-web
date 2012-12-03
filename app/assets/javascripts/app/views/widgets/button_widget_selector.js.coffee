class App.Views.ButtonWidgetImagesSelector extends Backbone.View
  template: JST["app/templates/widgets/button_selector"]

  initialize: (options) ->
    @widget = options.widget if options?.widget
    super

  render: ->
    @$el.html(@template(widget: @widget))
    @
