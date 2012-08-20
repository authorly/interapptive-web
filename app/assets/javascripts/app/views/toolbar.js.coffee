class App.Views.ToolbarView extends Backbone.View
  events:
    'click .add-scene'   : 'addScene'
    'click .add-keyframe': 'addKeyframe'
    'click .add-image'   : 'addImage'
    'click .add-text'    : 'addText'
    'click .add-touch'   : 'addTouch'
    'click .images'      : 'showImageLibrary'
    'click .videos'      : 'showVideoLibrary'
    'click .fonts'       : 'showFontLibrary'
    'click .sounds'      : 'showSoundLibrary'
    'click .actions'     : 'showActionLibrary'

  initialize: ->
    @assetLibraryView = new App.Views.AssetLibrary()

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
    App.modalWithView(view: App.imageList()).show()

  addText: ->
    # FIXME we should have some delegate that actually handles adding things
    #text = new App.Builder.Widgets.TextWidget(string: (prompt('Enter some text') or '<No Text>'))
    App.keyframeTextList().createText("Enter some text...")
    #keyframe = App.currentKeyframe()
    #TODO figure out whether we want to try to use the addwidget, etc functionality for text still
    #App.builder.widgetLayer.addWidget(text)
    #keyframe.addWidget(text)
    #text.on('change', -> keyframe.updateWidget(text))

  addTouch: ->
    alert('TODO show touch point dialogue here')
    widget = new App.Builder.Widgets.TouchWidget
    widget.setPosition(new cc.Point(300, 300))
    keyframe = App.currentKeyframe()
    App.builder.widgetLayer.addWidget(widget)
    keyframe.addWidget(widget)
    widget.on('change', -> keyframe.updateWidget(widget))


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

