class App.Views.TouchZoneIndex extends Backbone.View
  template: JST["app/templates/touch_zones/index"]

  initialize: (options) ->
    @widget = options.widget if options.widget

  render: ->
    $(@el).html(@template(widget: @widget, touchZone: @model))
    @appendForm()
    this

  model: App.Models.TouchZone

  appendForm: =>
    form = new Backbone.Form({ model: new @model() })
    form_el = form.render().el
    $(@el).find('#touch_zones.modal-body').append form_el
