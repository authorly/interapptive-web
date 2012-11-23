class App.Views.ToolbarView extends Backbone.View
  events:
    'click .scene'          :   'addScene'
    'click .keyframe'       :   'addKeyframe'
    'click .edit-text'      :   'addText'
    'click .touch-zones'    :   'addTouch'
    'click .preview'        :   'showPreview'
    'click .add-image'      :   'addSprite'
    'click .images'         :   'showImageLibrary'
    'click .videos'         :   'showVideoLibrary'
    'click .fonts'          :   'showFontLibrary'
    'click .sounds'         :   'showSoundLibrary'
    'click .actions'        :   'showActionLibrary'
    'click .scene-options'  :   'showSceneOptions'

  _addWidget: (widget) ->
    keyframe = App.currentKeyframe()
    App.builder.widgetLayer.addWidget(widget)
    keyframe.addWidget(widget)
    widget.on('change', -> keyframe.updateWidget(widget))


  addScene: ->
    # XXX in the `App.scenesCollection.models collection`, the addded scene
    # sometimes has the same id as the first scene, even though the
    # server's response is correct
    App.sceneList().createScene()


  addKeyframe: ->
    keyframe = new App.Models.Keyframe
      scene_id:   App.currentScene().get('id')
    keyframe.save {},
      success: ->
        # XXX necessary because this would blow if, in between `save` and
        # `success`, another scene was selected
        # This is a temporary fix; having the collection change contents is a bad
        # idea.
        if keyframe.get('scene_id') == App.currentScene().get('id')
          App.keyframesCollection.add keyframe


  showActionLibrary: ->
    @actionDefinitions = new App.Collections.ActionDefinitionsCollection()
    @actionDefinitions.fetch
      success: =>
        activeDefinition = @actionDefinitions.first
        view = new App.Views.ActionFormContainer(actionDefinitions: @actionDefinitions)
        App.modalWithView(view: view).show()

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
    App.Builder.Widgets.WidgetDispatcher.trigger('widget:touch:create')

  addSprite: ->
    imageSelected = (sprite) =>
      widget = new App.Builder.Widgets.SpriteWidget(
        url:      sprite.get('url'),
        filename: sprite.get('name'),
        zOrder:   $('#active-sprites-window ul li').size() || 1
        scale:    1.0
      )

      widget.setPosition(new cc.Point(300, 400))
      @_addWidget(widget)

      App.modalWithView().hide()
      view.off('image_select', imageSelected)

    view = new App.Views.SpriteIndex(collection: App.imagesCollection)
    view.on('image_select', imageSelected)

    App.modalWithView(view: view).show()
    view.fetchImages()

  showPreview: ->
    App.showSimulator()

  showSceneOptions: ->
    view = new App.Views.SceneForm()
    App.modalWithView(view: view).show()

  showImageLibrary: ->
    @loadDataFor("image")

  showVideoLibrary: ->
    @loadDataFor("video")

  showFontLibrary: ->
    @loadDataFor("font")

  showSoundLibrary: ->
    @loadDataFor("sound")

  loadDataFor: (assetType) ->
    @assetLibraryView = new App.Views.AssetLibrary(assetType)

    App.modalWithView(view: @assetLibraryView).show()
    @assetLibraryView.setAllowedFilesFor assetType + "s"
    @assetLibraryView.initAssetLibFor assetType + "s"
