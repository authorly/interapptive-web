class App.Views.ToolbarView extends Backbone.View
  events:
    'click .scene'        : 'addScene'
    'click .keyframe'     : 'addKeyframe'
    'click .edit-text'    : 'addText'
    'click .touch-zones'  : 'addTouch'
    'click .show-preview' : 'showPreview'
    'click .edit-sprite'  : 'addSprite'
    'click .images'       : 'showImageLibrary'
    'click .videos'       : 'showVideoLibrary'
    'click .fonts'        : 'showFontLibrary'
    'click .sounds'       : 'showSoundLibrary'
    'click .actions'      : 'showActionLibrary'

  render: ->
    $el = $(this.el)

  _addWidget: (widget) ->
    keyframe = App.currentKeyframe()
    App.builder.widgetLayer.addWidget(widget)
    keyframe.addWidget(widget)
    widget.on('change', -> keyframe.updateWidget(widget))

  addScene: ->
    @scene = App.sceneList().createScene()

  addKeyframe: ->
    App.keyframeList().createKeyframe()

  showActionLibrary: ->
    definitions = new App.Collections.ActionDefinitionsCollection()
    definitions.fetch
      success: ->
        App.modalWithView(view: new App.Views.ActionIndex(definitions: definitions)).show()

  addText: ->
    # FIXME we should have some delegate that actually handles adding things
    #text = new App.Builder.Widgets.TextWidget(string: (prompt('Enter some text') or '<No Text>'))
    t = App.keyframeTextList().createText("Enter some text...")
    #App.editTextWidget(App.keyframeTextList().createText("Enter some text...", true))

    #keyframe = App.currentKeyframe()
    #TODO figure out whether we want to try to use the addwidget, etc functionality for text still
    #App.builder.widgetLayer.addWidget(text)
    #keyframe.addWidget(text)
    #text.on('change', -> keyframe.updateWidget(text))

  addTouch: ->
    widget = new App.Builder.Widgets.TouchWidget
    widget.setPosition(new cc.Point(300, 300))
    @_addWidget(widget)

  addSprite: ->

    imageSelected = (sprite) =>
      widget = new App.Builder.Widgets.SpriteWidget(url: sprite.get('url'))
      widget.setPosition(new cc.Point(300, 400))
      @_addWidget(widget)

      App.modalWithView().hide()
      view.off('image_select', imageSelected)

    view = new App.Views.SpriteIndex(collection: App.imagesCollection)
    view.on('image_select', imageSelected)

    App.modalWithView(view: view).show()

  showPreview: ->
    App.showSimulator()

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

