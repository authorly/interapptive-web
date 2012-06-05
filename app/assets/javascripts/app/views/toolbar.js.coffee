class App.Views.ToolbarView extends Backbone.View
  events:
    'click .add-scene'   : 'addScene'
    'click .add-keyframe': 'addKeyframe'
    'click .edit-text'   : 'editText'
    'click .images'      : 'showImageLibrary'
    'click .videos'      : 'showVideoLibrary'
    'click .fonts'       : 'showFontLibrary'
    'click .sounds'      : 'showSoundLibrary'

  initialize: ->
    @assetLibraryView = new App.Views.AssetLibrary()

  render: ->
    $el = $(this.el)

  addScene: ->
    @scene = App.sceneList().createScene()

  addKeyframe: ->
    App.keyframeList().createKeyframe()

  editText: ->
    $("#text").focus() unless $('.edit-text').hasClass "disabled"

  showImageLibrary: ->
    @loadDataFor("image")

  showVideoLibrary: ->
    @loadDataFor("video")

  showFontLibrary: ->
    @loadDataFor("font")

  showSoundLibrary: ->
    @loadDataFor("sound")

  loadDataFor: (assetType) ->
    @assetLibraryView.activeAssetType = assetType
    App.modalWithView(view: @assetLibraryView).showModal()
    @assetLibraryView.setAllowedFilesFor assetType + "s"
    @assetLibraryView.initAssetLibFor assetType + "s"

