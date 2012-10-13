class App.Views.TouchZoneIndex extends App.Views.AbstractFormView
  events: ->
    _.extend({}, super, {
    })
    
  template: JST["app/templates/touch_zones/index"]

  initialize: (options) ->
    @widget = options.widget if options?.widget
    @collections = 
      videos: new App.Collections.VideosCollection()
      sounds: new App.Collections.SoundsCollection()
      actions: new App.Collections.ActionsCollection()
    super
    

  render: ->
    $(@el).html(@template(widget: @widget))
    $(@el).find('#touch_zones.modal-body').append @form.el
    this

  deleteMessage: ->
    "\nYou are about to delete this touch zone. This cannot be undone.\n\n\n" +
    "Are you sure you wish to continue?"


  formOptions: ->
    data: @widget
    schema:
      video_id:
        type: 'Select'
        options: @collections.videos.toSelectOptionGroup
        title: "Show video"
      sound_id:
        type: 'Select'
        options: @collections.sounds.toSelectOptionGroup
        title: "Play sound"
      #action_id:
        #type: 'Select'
        #options: @collections.actions.toSelectOptionGroup
        #title: "Perform action"

  resetValues: ->
    App.modalWithView().hide()

  updateAttributes: (e) =>
    e.preventDefault()
    @widget.loadFromHash @form.getValue(),
      success: (widget) -> 
        App.modalWithView().hide()

