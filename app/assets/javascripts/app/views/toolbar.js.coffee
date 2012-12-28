class App.Views.ToolbarView extends Backbone.View
  events:
    'click .scene'              : 'addScene'
    'click .keyframe'           : 'addKeyframe'
    'click .animation-keyframe' : 'addAnimationKeyframe'
    'click .edit-text'          : 'addText'
    'click .add-image'          : 'addSprite'
    'click .touch-zones'        : 'addTouch'
    'click .sync-audio'         : 'alignAudio'
    'click .images'             : 'showImageLibrary'
    'click .videos'             : 'showVideoLibrary'
    'click .fonts'              : 'showFontLibrary'
    'click .sounds'             : 'showSoundLibrary'
    'click .actions'            : 'showActionLibrary'
    'click .scene-options'      : 'showSceneOptions'
    'click .preview'            : 'showPreview'


  initialize: ->
    @_enableOnEvent 'scene:can_add_animation', '.animation-keyframe'
    @_enableOnEvent 'keyframe:can_add_text'  , '.edit-text'

    App.vent.on 'add:sprite', @addSprite

    App.vent.on 'keyframes:rendered',  =>
      new App.Views.FontToolbar()

    App.vent.on 'scene:active', (scene) =>
      @$('li').removeClass 'disabled'
      if scene.isMainMenu()
        @$('.edit-text,.touch-zones,.animation-keyframe,.keyframe').addClass 'disabled'


  addScene: ->
    scene = new App.Models.Scene
      storybook_id: App.currentStorybook().get 'id'

    App.scenesCollection.addScene scene


  addKeyframe: ->
    keyframe = new App.Models.Keyframe
      scene_id: App.currentScene().get 'id'

    App.keyframesCollection.addKeyframe keyframe


  addAnimationKeyframe: ->
    return if @$('.animation-keyframe.disabled').length > 0

    keyframe = new App.Models.Keyframe
      scene_id:     App.currentScene().get 'id'
      is_animation: true

    App.keyframesCollection.addKeyframe keyframe


  addText: ->
    #text = new App.Builder.Widgets.TextWidget(string: (prompt('Enter some text') or '<No Text>'))
    App.keyframeTextList().createText 'Enter some text...'


  addTouch: (event) ->
    return if $(event.currentTarget).hasClass('disabled')

    App.Builder.Widgets.WidgetDispatcher.trigger('widget:touch:create')


  addSprite: ->
    imageSelected = (image) =>
      widget = new App.Builder.Widgets.SpriteWidget
        url:      image.get 'url'
        filename: image.get 'name'
        scene:    App.currentScene()
        zOrder:   $('#active-sprites-window ul li').size() || 1
      widget.save()
      App.builder.widgetLayer.addWidget(widget)

      App.modalWithView().hide()

      view.off('select', imageSelected)

    view = new App.Views.SpriteIndex(collection: App.imagesCollection)
    view.on('select', imageSelected)
    App.modalWithView(view: view).show()


  alignAudio: ->
    view = new App.Views.AudioIndex App.currentKeyframe()
    App.modalWithView(view: view).show()

    # RFCTR - needs ventilation
    # App.vent.trigger 'audio:align'
    view.initAlignAudioModalInteractions()


  showSceneOptions: ->
    view = new App.Views.SceneForm()
    App.modalWithView(view: view).show()


  showImageLibrary: -> @loadDataFor 'image'


  showVideoLibrary: -> @loadDataFor 'video'


  showFontLibrary:  -> @loadDataFor 'font'


  showSoundLibrary: -> @loadDataFor 'sound'


  showPreview: -> App.showSimulator()


  showActionLibrary: ->
    @actionDefinitions = new App.Collections.ActionDefinitionsCollection()
    @actionDefinitions.fetch
      success: =>
        activeDefinition = @actionDefinitions.first
        view = new App.Views.ActionFormContainer actionDefinitions: @actionDefinitions
        App.modalWithView(view: view).show()


  loadDataFor: (assetType) ->
    view = new App.Views.AssetLibrary assetType
    App.modalWithView(view: view).show()

    # Needs ventilation
    view.setAllowedFilesFor "#{assetType}s"
    view.initAssetLibFor "#{assetType}s"


  _addWidget: (widget) ->
    keyframe = App.currentKeyframe()
    App.builder.widgetLayer.addWidget widget
    keyframe.addWidget widget

    widget.on 'change', -> keyframe.updateWidget widget


  _enableOnEvent: (event, selector) ->
    App.vent.on event, (enable) =>
      element = @$(selector)
      if enable
        element.removeClass 'disabled'
      else
        element.addClass 'disabled'
