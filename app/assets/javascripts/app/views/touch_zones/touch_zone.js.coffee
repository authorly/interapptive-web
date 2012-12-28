class App.Views.TouchZoneIndex extends App.Views.AbstractFormView
  events: ->
    _.extend({}, super, {
      'change select#on_touch': "populateAssets"
    })

  template: JST["app/templates/touch_zones/index"]

  initialize: (options) ->
    @widget = options.widget if options?.widget
    @collections =
      videos: new App.Collections.VideosCollection()
      sounds: new App.Collections.SoundsCollection()
    super

  render: ->
    $(@el).html(@template(widget: @widget))
    $(@el).find('#touch_zones.modal-body').append @form.el
    @attachDeleteButton() if @widget?.id
    this

  attachDeleteButton: ->
    $button = $('<button />', {
      'class': 'btn btn-primary btn-danger widget-delete',
      text: "Delete",
    })
    $(@form.el).find('fieldset').after($button)


  delete: (e) =>
    App.currentScene().removeWidget(@widget)
    App.builder.widgetLayer.removeWidget(@widget)
    App.currentKeyframe().widgetsChanged()
    App.modalWithView().hide()
    @cancel(e)


  deleteMessage: ->
    "\nYou are about to delete this hotspot. This cannot be undone.\n\n\n" +
    "Are you sure you wish to continue?"


  formOptions: ->
    data: @widget
    schema:
      on_touch:
        type: 'Select'
        options: ['Select video or sound...', 'Show video', 'Play sound']
        title: "On touch"
      asset_id:
        type: 'Select'
        options: []
        title: "Media to play"


  resetValues: ->
    App.modalWithView().hide()


  updateAttributes: (e) =>
    e.preventDefault()

    # Creates either sound_id or video_id key/value pair for passing to new touch widget
    touch_options = {}
    touch_options[@keysForSelect[@form.getValue().on_touch]] = @form.getValue().asset_id

    @widget = App.Builder.Widgets.WidgetDispatcher.createWidget(touch_options) unless @widget?.id

    hashForWidget = @prepareHashForWidget(@form.getValue())
    @widget.loadFromHash hashForWidget,
      success: (widget) ->
        App.modalWithView().hide()


  prepareHashForWidget: (form_value) ->
    hash = new Object()
    hash[@keysForSelect[form_value.on_touch]] = form_value.asset_id
    hash


  keysForSelect:
    'Show video': 'video_id',
    'Play sound': 'sound_id',


  populateAssetsFor: (asset_type) ->
    $asset_ids = $('#asset_id').html('')
    @collections[asset_type].fetch
      success: =>
        _.each @collections[asset_type].models, (m) ->
          $asset_ids.append($('<option />').val(m.get('url')).text(m.get('name')))


  populateAssets: (e) ->
    $asset_type = $(e.target)

    switch $asset_type.val()
      when 'Show video'
        @populateAssetsFor('videos')
      when 'Play sound'
        @populateAssetsFor('sounds')
      else
        $('#asset_id').html('<option></option>')
