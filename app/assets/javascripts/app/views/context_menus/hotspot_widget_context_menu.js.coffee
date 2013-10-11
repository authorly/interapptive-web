#= require ./context_menu

class App.Views.HotspotWidgetContextMenu extends App.Views.ContextMenu

  events: ->
    _.extend {}, super,
      'change #asset_id':               'assetSelected'
      'change #asset-glitter-checkbox': 'changeGlitterState'

  template: JST["app/templates/context_menus/hotspot_widget_context_menu"]


  initialize: ->
    super
    storybook = @widget.collection.keyframe.scene.storybook

    @collections =
      videos: storybook.videos
      sounds: storybook.sounds


  render: ->
    @$el.html(@template())

    @form = new Backbone.Form(@_formOptions()).render()
    @$el.find('#asset-selector').append(@form.el)
    @_setGlitterState()

    @_renderCoordinates @$('#hotspot-coordinates')

    @_selectAsset()

    @


  changeGlitterState: (event) ->
    @widget.set('glitter', !@widget.get('glitter'))


  assetSelected: (event) =>
    @_setAssetId @form.getValue()?.asset_id


  remove: ->
    @form.remove()
    @_removeCoordinates()
    super


  _setGlitterState: ->
    if @widget.get('glitter')
      @$el.find('#asset-glitter-checkbox').attr('checked', 'checked')


  _formOptions: ->
    data: @widget
    schema:
      asset_id:
        type: "Select"
        title: ""
        options: [
          { group: 'Show Video', options: @_populateAssetsFor('videos') }
          { group: 'Play Sound', options: @_populateAssetsFor('sounds') }
        ]


  _populateAssetsFor: (asset_type) ->
    return "<option disabled='true'>There are no uploaded #{asset_type}.</option>" if @collections[asset_type].length is 0
    @collections[asset_type]


  # Returns correct key name to be used for the asset that is being
  # attached with a Hotspot. This leverages the fact that no two
  # Storybook#sounds or Storybook#videos have same id. This is
  # because Sound and Video, in Rails, inherit from Asset and have
  # same table in the database i.e. 'assets'.
  _assetKey: (asset_id) ->
    return 'video_id' if @collections.videos.get(asset_id)
    return 'sound_id' if @collections.sounds.get(asset_id)
    throw new Error("Asset was not found in collection")


  _setAssetId: (id) ->
    return unless id?

    @widget.unset('sound_id'); @widget.unset('video_id')
    @widget.set @_assetKey(id), id


  _selectAsset: ->
    @$("option[value='#{@widget.assetId()}']").attr('selected', 'selected')
