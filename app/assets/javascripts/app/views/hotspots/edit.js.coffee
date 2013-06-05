# Create/edit hotspot
class App.Views.Hotspot extends App.Views.AbstractFormView
  template: JST['app/templates/hotspots/edit']

  initialize: (options) ->
    @widget = options.widget if options?.widget
    @storybook = options.storybook

    @collections =
      videos: @storybook.videos
      sounds: @storybook.sounds
    super


  render: ->
    @$el.html(@template(widget: @widget))
    @$el.find('.modal-body').append(@form.el)
    @_selectOption()
    @_showUploadAssetMessage()
    @attachDeleteButton() if @widget?.id
    @


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
      asset_id:
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
        @_setAssetIdToWidget(touch_options)
      else
        App.vent.trigger('create:widget', _.extend(touch_options, {type: 'HotspotWidget'}))

    App.vent.trigger('hide:modal')


  # Creates either sound_id or video_id key/value pair for passing to new touch widget
  prepareHashForWidget: (form_value) ->
    hash = {}
    try
      hash[@keyForSelect(form_value.asset_id)] = form_value.asset_id
    catch e
      hash = null
    hash


  # Returns correct key name to be used for the asset that is being
  # attached with a Hotspot. This leverages the fact that no two
  # Storybook#sounds or Storybook#videos have same id. This is
  # because Sound and Video, in Rails, inherit from Asset and have
  # same table in the database i.e. 'assets'.
  keyForSelect: (asset_id) ->
    return 'video_id' if @collections.videos.get(asset_id)
    return 'sound_id' if @collections.sounds.get(asset_id)
    throw new Error("Asset was not found in collection")


  populateAssetsFor: (asset_type) ->
    return "<option disabled='true'>There are no uploaded #{asset_type}.</option>" if @collections[asset_type].length is 0
    @collections[asset_type]


  _showUploadAssetMessage: ->
    if @collections.videos.length is 0 and @collections.sounds.length is 0
      @form.$el.hide()
      @$('.modal-body').html("<center>There are no uploaded videos or sounds.</center>")


  _selectOption: ->
    return unless @widget?
    @$("option[value='#{@widget.assetId()}']").attr('selected', 'selected')


  _setAssetIdToWidget: (options) ->
    if options.video_id?
      @widget.unset('sound_id')
    else if options.sound_id?
      @widget.unset('video_id')
    @widget.set(options)
