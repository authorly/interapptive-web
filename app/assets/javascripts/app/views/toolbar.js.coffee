class App.Views.ToolbarView extends Backbone.View
  events:
    'click .scene'              : 'addScene'
    'click .keyframe'           : 'addKeyframe'
    'click .animation-keyframe' : 'addAnimationKeyframe'
    'click .edit-text'          : 'addText'
    'click .touch-zones'        : 'addTouch'
    'click .preview'            : 'showPreview'
    'click .add-image'          : 'addSprite'
    'click .images'             : 'showImageLibrary'
    'click .videos'             : 'showVideoLibrary'
    'click .fonts'              : 'showFontLibrary'
    'click .sounds'             : 'showSoundLibrary'
    'click .actions'            : 'showActionLibrary'
    'click .scene-options'      : 'showSceneOptions'
    'click .sync-audio'   : 'showAlignAudioModal'


  initialize: ->
    @_enableOnEvent 'scene:can_add_animation', '.animation-keyframe'
    @_enableOnEvent 'keyframe:can_add_text', '.edit-text'


  _enableOnEvent: (event, selector) ->
    App.vent.on event, (enable) =>
      element = @$(selector)
      if enable
        element.removeClass 'disabled'
      else
        element.addClass 'disabled'


  _addWidget: (widget) ->
    keyframe = App.currentKeyframe()
    App.builder.widgetLayer.addWidget(widget)
    keyframe.addWidget(widget)
    widget.on('change', -> keyframe.updateWidget(widget))

  addScene: ->
    # XXX in the `App.scenesCollection.models collection`, the addded scene
    # sometimes has the same id as the first scene, even though the
    # server's response is correct
    scene = App.sceneList().createScene()
    scene._getKeyframes()


  addKeyframe: ->
    @_addKeyframe (new App.Models.Keyframe)


  addAnimationKeyframe: ->
    return if @$('.animation-keyframe.disabled').length > 0

    @_addKeyframe (new App.Models.Keyframe(is_animation: true))


  _addKeyframe: (keyframe) ->
    collection = App.keyframesCollection
    # REFACTOR: Code related to widgets system probably does not belong here
    # it should be moved to somewhere else.
    sprite_orientation_widgets = _.map(App.currentScene().spriteWidgets(), (sprite_widget) ->
      new App.Builder.Widgets.SpriteOrientationWidget(
        keyframe: keyframe
        sprite_widget: sprite_widget
        sprite_widget_id: sprite_widget.id
      )
    )
    keyframe.set
      scene_id: App.currentScene().get('id')
      position: collection.nextPosition(keyframe)
      widgets: _.map(sprite_orientation_widgets, (w) -> w.toHash() )

    keyframe.save {},
      success: ->
        # XXX necessary because this would blow if, in between `save` and
        # `success`, another scene was selected
        # This is a temporary fix; having the collection change contents is a bad
        # idea.
        if keyframe.get('scene_id') == collection.scene_id
          collection.add keyframe
          _.each(sprite_orientation_widgets, (w) ->
            App.storybookJSON.addSpriteOrientationWidget(w)
            App.builder.widgetStore.addWidget(w)
          )

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
    imageSelected = (image) =>
      widget = new App.Builder.Widgets.SpriteWidget(
        url:      image.get('url'),
        filename: image.get('name'),
        zOrder:   $('#active-sprites-window ul li').size() || 1
        scene:    App.currentScene()
      )
      widget.save()
      App.builder.widgetLayer.addWidget(widget)
      App.modalWithView().hide()
      view.off('image_select', imageSelected)

    view = new App.Views.SpriteIndex(collection: App.imagesCollection)
    view.on('image_select', imageSelected)

    App.modalWithView(view: view).show()
    view.fetchImages()

  showAlignAudioModal: ->
    view = new App.Views.AudioIndex(App.currentKeyframe())
    App.modalWithView(view: view).show()
    view.initAlignAudioModalInteractions()


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
