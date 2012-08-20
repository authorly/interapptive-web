class App.Views.ToolbarView extends Backbone.View
  events:
    'click .add-scene'   : 'addScene'
    'click .add-keyframe': 'addKeyframe'
    'click .add-image'   : 'addImage'
    'click .add-text'    : 'addText'
    'click .images'      : 'showImageLibrary'
    'click .videos'      : 'showVideoLibrary'
    'click .fonts'       : 'showFontLibrary'
    'click .sounds'      : 'showSoundLibrary'
    'click .actions'     : 'showActionLibrary'

  initialize: ->

  render: ->
    $el = $(this.el)

  addScene: ->
    @scene = App.sceneList().createScene()

  addKeyframe: ->
    App.keyframeList().createKeyframe()

  showActionLibrary: ->
    definitions = new App.Collections.ActionDefinitionsCollection()
    definitions.fetch
      success: ->
        App.modalWithView(view: new App.Views.ActionIndex(definitions: definitions)).showModal()

  addImage: ->
    images = new App.Collections.ImagesCollection()
    App.modalWithView(view: new App.Views.ImageIndex(collection: images)).show()

  addText: ->
    text = new App.Builder.Widgets.TextWidget(string: (prompt('Enter some text') or '<No Text>'))
    text.setPosition(new cc.Point(100, 100))
    App.builder.widgetLayer.addWidget(text)

  showImageLibrary: ->
    @loadDataFor("image")

  showVideoLibrary: ->
    @loadDataFor("video")

  showFontLibrary: ->
    @loadDataFor("font")

  showSoundLibrary: ->
    @loadDataFor("sound")

  loadDataFor: (assetType) ->
    @assetLibraryView = new App.Views.AssetLibrary()

    @assetLibraryView.activeAssetType = assetType
    App.modalWithView(view: @assetLibraryView).show()
    @assetLibraryView.setAllowedFilesFor assetType + "s"
    @assetLibraryView.initAssetLibFor assetType + "s"

