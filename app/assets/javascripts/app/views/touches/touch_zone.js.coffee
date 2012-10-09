class App.Views.TouchZoneIndex extends App.Views.AbstractFormView
  events: ->
    _.extend({}, super, {
    })
    
  template: JST["app/templates/touch_zones/index"]

  initialize: (options) ->
    @model = new App.Models.TouchZone()
    @widget = options.widget if options?.widget
    super

  render: ->
    $(@el).html(@template(widget: @widget))
    $(@el).find('#touch_zones.modal-body').append @form.el
    this

  deleteMessage: ->
    "\nYou are about to delete this touch zone. This cannot be undone.\n\n\n" +
    "Are you sure you wish to continue?"

  resetValues: ->

