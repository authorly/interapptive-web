class App.Views.HotspotsIndex extends App.Views.AbstractFormView
  template: JST['app/templates/touch_zones/index']

  initialize: (options) ->
    @widget = options.widget if options?.widget
    @storybook = options.storybook

    @collections =
      videos: @storybook.videos
      sounds: @storybook.sounds
    super


  render: ->
    @$el.html(@template(widget: @widget))
    @$el.find('#touch_zones.modal-body').append(@form.el)
    @attachDeleteButton() if @widget?.id
    this


  attachDeleteButton: ->
    $button = $('<button />', {
      'class': 'btn btn-primary btn-danger widget-delete',
      text: "Delete",
    })
    @form.$el.find('div.form-actions').prepend($button)


  delete: (e) =>
    @widget.collection.remove(@widget)
    @cancel(e)


  deleteMessage: ->
    "\nYou are about to delete this hotspot. This cannot be undone.\n\n\n" +
    "Are you sure you wish to continue?"


  formOptions: ->
    data: @widget
    schema:
      asset_url:
        type: "Select"
        title: "On touch"
        options: [
          { group: 'Show Video', options: @populateAssetsFor('videos') }
          { group: 'Play Sound', options: @populateAssetsFor('sounds') }
        ]


  updateAttributes: (event) =>
    event.preventDefault()
    touch_options = @prepareHashForWidget(@form.getValue())

    if touch_options?
      if @widget?.id
        @widget.set(touch_options)
      else
        App.vent.trigger('create:widget', _.extend(touch_options, {type: 'HotspotWidget'}))

    App.vent.trigger('hide:modal')


  # Creates either sound_id or video_id key/value pair for passing to new touch widget
  prepareHashForWidget: (form_value) ->
    hash = {}
    try
      hash[@keyForSelect(form_value.asset_url)] = form_value.asset_url
    catch e
      hash = null
    hash


  keyForSelect: (asset_url) ->
    return 'video_id' if _.map(@collections.videos.models, (m) -> m.get('url')).indexOf(asset_url) > -1
    return 'sound_id' if _.map(@collections.sounds.models, (m) -> m.get('url')).indexOf(asset_url) > -1
    throw new Error("Asset was not found in collection")


  populateAssetsFor: (asset_type) ->
    _.map @collections[asset_type].models, (m) =>
      "<option value='#{m.get('url')}' selected='#{@_selectedAsset(m)}'>" + m.get('name') + "</option>"
    .join('')


  _selectedAsset: (asset) ->
    return '' unless @widget?
    asset.get('url') is @widget.get('sound_id') or
      asset.get('url') is @widget.get('video_id')
