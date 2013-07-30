window.App =

  Models:      {}
  Views:       {}
  Collections: {}
  Routers:     {}
  Lib:         {}
  Mixins:      {}
  Config:      {}

  init: ->
    # A global vent object that allows decoupled communication between
    # different parts of the application. For example, the content of the
    # main view and the buttons in the toolbar.
    @vent = _.extend {}, Backbone.Events

    @vent.on 'reset:palettes',           @_resetPalettes,    @
    @vent.on 'toggle:palette',           @_togglePalette,    @
    @vent.on 'hide:modal',               @_hideModal,        @
    @vent.on 'show:imageLibrary',        @_showImageLibrary, @
    @vent.on 'show:message',             @_showToast,        @

    @vent.on 'create:scene',    @_addNewScene,    @
    @vent.on 'create:keyframe', @_addNewKeyframe, @
    @vent.on 'create:widget',   @_addNewWidget,   @

    @vent.on 'show:settingsform',  @_showSettings, @
    @vent.on 'show:scenebackgroundsoundform', @_showBackgroundSoundForm, @

    @vent.on 'change:keyframeWidgets', @_changeKeyframeWidgets, @
    @vent.on 'load:sprite',            @_changeSceneWidgets,    @

    @vent.on 'play:video', @_playVideo, @

    @vent.on 'show:simulator', @showSimulator

    @currentSelection = new Backbone.Model
      storybook: null
      scene: null
      keyframe: null
      text_widget: null
    @currentWidgets = new App.Collections.CurrentWidgets()

    @toolbar   = new App.Views.ToolbarView  el: $('#toolbar')
    @file_menu = new App.Views.FileMenuView el: $('#file-menu')

    @context_menu = new App.Views.ContextMenuContainer el: $('#context-menu-container')

    @spritesListPalette = new App.Views.PaletteContainer
      view       : new App.Views.SpriteListPalette()
      el         : $('#sprite-list-palette')
      title      : 'Active Scene Images'
      alsoResize : '#sprite-list-palette ul li span'

    @textEditorPalette = new App.Views.PaletteContainer
      title: 'Font Settings'
      view : new App.Views.TextEditorPalette
      el   : $('#text-editor-palette')

    @assetLibrarySidebar= new App.Views.AssetLibrarySidebar
      el: $('#asset-library-sidebar')

    @_makeCanvasDroppable()

    @palettes = [ @textEditorPalette, @spritesListPalette ]

    @currentSelection.on 'change:storybook', @_openStorybook,  @
    @currentSelection.on 'change:scene',     @_changeScene,    @
    @currentSelection.on 'change:keyframe',  @_changeKeyframe, @
    @currentSelection.on 'change:widget',    @_changeWidget,   @

    @initializeGlobalSync()


  _makeCanvasDroppable: ->
    canvas = $('#builder-canvas')
    canvasAttributes =
      height: canvas.height()
      offset: canvas.offset()
      scale:  canvas.attr('height') / canvas.height()
      margins:
        top: 200
        left: 125
    canvas.droppable
      accept: '.asset'
      drop: (__, ui) =>
        offset = canvas.offset()
        position =
          x: (ui.position.left - offset.left - canvasAttributes.margins.left + ui.helper.width() * 0.5) * canvasAttributes.scale
          y: canvasAttributes.height - ((ui.position.top - offset.top - canvasAttributes.margins.top) + ui.helper.height() * 0.5) * canvasAttributes.scale
        @_assetDropped
          id:   ui.draggable.data('id')
          type: ui.draggable.data('type')
          position: position
    @vent.on 'assetDrag-start', (-> canvas.addClass    'highlight')
    @vent.on 'assetDrag-stop',  (-> canvas.removeClass 'highlight')


  saveCanvasAsPreview: ->
    window.setTimeout ( ->
      keyframe = App.currentSelection.get('keyframe')
      App.Builder.Widgets.WidgetLayer.updateKeyframePreview(keyframe)
    ), 200 # wait for the changes to be shown in the canvas


  _togglePalette: (palette) ->
    # translate from generic event names to variable names in this file
    # (to avoid coupling the names)
    palette = switch palette
      when 'sceneImages' then @spritesListPalette
      when 'fontEditor'  then @textEditorPalette
    palette.$el.toggle() if palette?


  _openStorybook: (__, storybook) ->
    scenesIndex = new App.Views.SceneIndex(collection: storybook.scenes)
    $('#scene-list').html(scenesIndex.render().el)

    storybook.widgets.on 'change', =>
      keyframe = App.currentSelection.get('keyframe')
      @saveCanvasAsPreview()

    storybook.scenes.on 'change:widgets', =>
      keyframe = App.currentSelection.get('keyframe')
      @saveCanvasAsPreview()

    storybook.scenes.on 'synchronization-start synchronization-end', (__, synchronizing) =>
      @vent.trigger 'can_add:scene', !synchronizing

    storybook.scenes.on 'reset', (scenes) ->
      # The simulator needs all the information upfront
      scenes.each (scene) ->
        scene.fetchKeyframes()

    storybook.fetchCollections()

    @textEditorPalette.view.openStorybook(storybook)

    assets = new App.Lib.AggregateCollection([], collections: [storybook.images, storybook.videos, storybook.sounds])
    assets.storybook = storybook
    @assetLibrarySidebar.setAssets assets


  _showSettings: ->
    view = new App.Views.SettingsContainer(model: App.currentSelection.get('scene'))
    App.modalWithView(view: view).show()


  _showBackgroundSoundForm: ->
    view = new App.Views.BackgroundSoundForm(model: App.currentSelection.get('scene'))
    App.modalWithView(view: view).show()


  _changeScene: (selection, scene) ->
    previousScene = selection.previous('scene')
    @_removeSceneListeners(previousScene)
    @_addSceneListeners(scene)

    App.vent.trigger 'activate:scene', scene
    @vent.trigger 'can_add:keyframe', scene.canAddKeyframes()
    @vent.trigger 'can_add:animationKeyframe', scene.canAddAnimationKeyframe()
    @vent.trigger 'has_background_sound:scene', scene.hasBackgroundSound()

    @keyframesView.remove() if @keyframesView?
    @keyframesView = new App.Views.KeyframeIndex(collection: scene.keyframes)
    $('#keyframe-list').html @keyframesView.render().el
    scene.fetchKeyframes()

    @spritesListPalette.view.setCollection(scene.widgets)


  _addSceneListeners: (scene) ->
    if scene?
      scene.widgets.on    'remove', @_checkCurrentWidgetRemoved, @
      scene.keyframes.on  'reset add remove', @_announceSceneAnimation, @
      scene.keyframes.on  'synchronization-start synchronization-end', @_keyframesSynchronization, @


  _removeSceneListeners: (scene) ->
    if scene?
      scene.widgets.off   'remove', @_checkCurrentWidgetRemoved, @
      scene.keyframes.off 'reset add remove', @_announceSceneAnimation, @
      scene.keyframes.off 'synchronization-start synchronization-end', @_keyframesSynchronization, @


  _keyframesSynchronization: (__, synchronizing) ->
    scene = App.currentSelection.get('scene')
    @vent.trigger 'can_add:keyframe', !synchronizing && scene.canAddKeyframes()
    @vent.trigger 'can_add:animationKeyframe', !synchronizing && scene.canAddAnimationKeyframe()


  _announceSceneAnimation: (keyframes) ->
    App.vent.trigger 'can_add:animationKeyframe', keyframes.scene.canAddAnimationKeyframe()


  _checkCurrentWidgetRemoved: (widget) ->
    if App.currentSelection.get('widget') == widget
      App.currentSelection.set widget: null


  _changeKeyframe: (selection, keyframe) ->
    previousKeyframe = selection.previous('keyframe')
    @_removeKeyframeListeners(previousKeyframe)
    @_addKeyframeListeners(keyframe)

    @currentWidgets.changeKeyframe(keyframe)

    if keyframe?
      App.vent.trigger 'can_add:text', keyframe.canAddText()
      keyframe.announceVoiceover()
      @saveCanvasAsPreview() if keyframe.preview.isNew()


  _addKeyframeListeners: (keyframe) ->
    if keyframe?
      keyframe.widgets.on  'remove', @_checkCurrentWidgetRemoved, @
      keyframe.widgets.on  'reset add remove', keyframe.announceVoiceover, keyframe


  _removeKeyframeListeners: (keyframe) ->
    if keyframe?
      keyframe.widgets.off 'remove', @_checkCurrentWidgetRemoved, @
      keyframe.widgets.off 'reset add remove', keyframe.announceVoiceover, keyframe


  _changeKeyframeWidgets: (keyframe) ->
    @saveCanvasAsPreview() if App.currentSelection.get('keyframe') == keyframe


  _changeSceneWidgets: ->
    @saveCanvasAsPreview()


  _addNewScene: ->
    App.currentSelection.get('storybook').addNewScene()


  _addNewKeyframe: (attributes) ->
    App.currentSelection.get('scene').addNewKeyframe(attributes)


  _addNewWidget: (attributes) ->
    containerType = App.Collections.Widgets.containers[attributes.type]
    container = App.currentSelection.get(containerType)
    collection = container.widgets
    widget = collection.model(attributes)

    if widget instanceof App.Models.HotspotWidget and !container.canAddHotspot()
      alert 'Cannot add Hotspots to this scene'
      return

    collection.add widget

    window.setTimeout (-> App.currentSelection.set widget: widget), 0


  # @param [Object] attributes
  # @option attributes [Integer] id
  # @option attributes [String] type ('image', 'sound' or 'video')
  # @option attributes [Object] position {x, y}
  _assetDropped: (attributes={}) ->
    scene = App.currentSelection.get('scene')

    widgetAttributes =
      position: $.extend {}, attributes.position
    widgetAttributes[attributes.type + '_id'] = attributes.id

    switch attributes.type
      when 'image'
        widgetAttributes.type = 'SpriteWidget'
        widgetAttributes.scale = 1
        break
      when 'sound', 'video'
        widgetAttributes.type = 'HotspotWidget'
        break

    @_addNewWidget(widgetAttributes)


  _resetPalettes: ->
    palette.reset() for palette in @palettes


  initModals: ->
    $('.content-modal').modal(backdrop: true).modal('hide')
    $('.lightbox-modal').modal().modal('hide')

    # RFCTR: Should use generic modal view
    $('#storybooks-modal').modal
      backdrop : 'static'
      show     : true
      keyboard : false


  modalWithView: (view) ->
    if view?
      @view = new App.Views.Modal view, className: 'content-modal'

    @view


  lightboxWithView: (view) ->
    if view?
      @lightboxView = new App.Views.Lightbox view, className: 'lightbox-modal'
    @lightboxView


  _hideModal: ->
    @modalWithView()?.hide()


  _playVideo: (videoView) ->
    App.vent.trigger('hide:modal')
    @lightboxWithView(view: videoView).show()


  _showImageLibrary: ->
    @file_menu.showImageLibrary()


  _showToast: (type, message) ->
    window.toastr[type](message)


  _changeWidget: (selection, widget) ->
    @_triggerCurrentWidgetChangeEvent(selection, widget)

    @spritesListPalette.view.spriteSelected(widget)


  # Translates an App.currentSelection.on(widget:change) event
  # to a widget specific event on App.vent.
  #
  # e.g. When user selects a TextWidget, it translates
  # 'widget:change' to 'activate:textWidget' which other views
  # can listen to and take action. This has advantage that
  # views listening to change:widget event wont have to have
  # code that checks the type of widget that was changed.
  # activate event receives the current widget that was set.
  #
  # In case of widget is change to null, corresponding 'deactivate'
  # event is triggered e.g. 'deactivate:textWidget'. deactivate
  # receives previous widget that was set.
  _triggerCurrentWidgetChangeEvent: (selection, widget) ->
    if widget?
      @vent.trigger('activate:' + App.Lib.StringHelper.decapitalize(widget.get('type')), widget)
    else
      previous_widget = selection.previous('widget')
      if previous_widget?
        @vent.trigger('deactivate:' + App.Lib.StringHelper.decapitalize(previous_widget.get('type')), previous_widget)


  showSimulator: =>
    storybook = App.currentSelection.get('storybook')
    json = new App.JSON(storybook).app
    console.log JSON.stringify(json)
    # @simulator ||= new App.Views.Simulator(json: App.storybookJSON.toString())


  initializeGlobalSync: ->
    # A global vent for synchronization events
    @syncVent = new App.Lib.SynchronizationVent
    syncMixin =
      # By default, all models (that have synchronization enabled) trigger
      # synchronization events both on the object itself and on the global vent
      syncVents: ->
        [App.syncVent, @]

    _.extend Backbone.Model::,      syncMixin
    _.extend Backbone.Collection::, syncMixin

    @syncing = $('#global-sync-indicator img')
    @syncVent.on 'start', (-> @syncing.css('visibility', 'visible')), @
    @syncVent.on 'end',   (-> @syncing.css('visibility', 'hidden' )), @


  start: ->
    App.version =
      environment: $('#rails-environment').data('rails-environment'),
      git_head:    $('#rails-environment').data('git-head')

    App.init()

    window.initBuilder()

    $(window).resize -> App.vent.trigger('window:resize')
    App.initModals()

    @storybooksRouter = new App.Routers.StorybooksRouter
    Backbone.history.start()

