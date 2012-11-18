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
      on_touch:
        type: 'Select'
        options: ['', 'Show video', 'Play sound']
        title: "On touch"
      asset_id:
        type: 'Select'
        options: []
        title: ""

  resetValues: ->
    App.modalWithView().hide()

  updateAttributes: (e) =>
    e.preventDefault()
    @widget.loadFromHash @prepareHashForWidget(@form.getValue()),
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
          $asset_ids.append($('<option />').val(m.get('id')).text(m.get('name')))

  populateAssets: (e) ->
    $asset_type = $(e.target)

    switch $asset_type.val()
      when 'Show video'
        @populateAssetsFor('videos')
      when 'Play sound'
        @populateAssetsFor('sounds')
      else
        $('#asset_id').html('<option></option>')
