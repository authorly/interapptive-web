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

  initialize: ->
    @assetLibraryView = new App.Views.AssetLibrary()

  render: ->
    $el = $(this.el)

  addScene: ->
    @scene = App.sceneList().createScene()

  addKeyframe: ->
    App.keyframeList().createKeyframe()

  addImage: ->
    App.modalWithView(view: App.imageList()).show()

  addText: ->
    # FIXME we should have some delegate that actually handles adding things
    text = new App.Builder.Widgets.TextWidget(string: (prompt('Enter some text') or '<No Text>'))
    text.setPosition(new cc.Point(100, 100))
    keyframe = App.currentKeyframe()
    App.builder.widgetLayer.addWidget(text)
    keyframe.addWidget(text)
    text.on('change', -> keyframe.updateWidget(text))

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
    App.modalWithView(view: @assetLibraryView).show()
    @assetLibraryView.setAllowedFilesFor assetType + "s"
    @assetLibraryView.initAssetLibFor assetType + "s"

