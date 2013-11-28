window.App =

  Models:      {}
  Views:       {}
  Collections: {}
  Routers:     {}
  Lib:         {}
  Mixins:      {}
  Config:      {}

  init: ->
    App.version =
      environment: $('#rails-environment').data('rails-environment'),
      git_head:    $('#rails-environment').data('git-head')

    # A global vent object that allows decoupled communication between
    # different parts of the application. For example, the content of the
    # main view and the buttons in the toolbar.
    @vent = _.extend {}, Backbone.Events

    @initializeMixpanel()
    @initializeGlobalSync()

    @vent.on 'hide:modal',   @_hideModal, @
    @vent.on 'show:message', @_showToast, @


  initStorybook: ->
    @currentSelection = new Backbone.Model
      storybook: null
      scene: null
      keyframe: null
      text_widget: null
    @currentWidgets = new App.Collections.CurrentWidgets()

    @currentSelection.on 'change:storybook', @_openStorybook,  @
    @currentSelection.on 'change:scene',     @_changeScene,    @
    @currentSelection.on 'change:keyframe',  @_changeKeyframe, @
    @currentSelection.on 'change:widget',    @_changeWidget,   @

    @vent.on 'show:fontLibrary',         @_showFontLibrary,  @

    @vent.on 'create:scene',    @_addNewScene,    @
    @vent.on 'create:widget',   @_addNewWidget,   @

    @vent.on 'show:settingsform',             @_showSettings,            @
    @vent.on 'show:scenebackgroundsoundform', @_showBackgroundSoundForm, @

    @vent.on 'bring_to_front:sprite', @_bringToFront, @
    @vent.on 'put_in_back:sprite',    @_putInBack,    @

    @vent.on 'play:video', @_playVideo, @

    @vent.on 'show:simulator', @showSimulator

    @toolbar   = new App.Views.ToolbarView  el: $('#toolbar')
    @fontCache    = new App.Views.FontCache            el: $('#storybook-font-cache')
    @context_menu = new App.Views.ContextMenuContainer el: $('#context-menu-container')

    @assetLibrarySidebar= new App.Views.AssetLibrarySidebar
      el: $('#asset-library-sidebar')

    @_makeCanvasDroppable()

    App.initModals()


  _hideModal: ->
    @modalWithView()?.hide()


  # Shows a notification `message` on top right of the browser.
  # type is one of:
  # `success` - Green
  # `info`    - Blue
  # `warning` - Yellow
  # `error`   - Red
  _showToast: (type, message) ->
    window.toastr[type](message)


  _makeCanvasDroppable: ->
    canvas = $('#builder')
    canvas.droppable
      accept: '.js-draggable'
      drop: (event, ui) =>
        onOtherElements = $('.navbar, .sidebar').filter (__, el) ->
          el = $(el)
          x = el.offset().left; y = el.offset().top
          x <= event.pageX && event.pageX <= x + el.outerWidth() && y <= event.pageY && event.pageY <= y + el.outerHeight()
        return if onOtherElements.length > 0

        offset = canvas.offset()
        position =
          x: App.Config.dimensions.width / 2
          y: App.Config.dimensions.height / 2
        element = ui.helper
        @_assetDropped
          id:   element.data('id')
          type: element.data('type')
          position: position


  _openStorybook: (__, storybook) ->
    scenesIndex = new App.Views.SceneIndex(collection: storybook.scenes)
    $('#scene-list').html(scenesIndex.render().el)

    storybook.scenes.on 'synchronization-start synchronization-end', (__, synchronizing) =>
      @vent.trigger 'can_add:scene', !synchronizing

    storybook.scenes.on 'reset', (scenes) ->
      # The simulator needs all the information upfront
      scenes.each (scene) ->
        scene.fetchKeyframes()

    storybook.fetchCollections()

    @fontCache.openStorybook(storybook)

    assets = new App.Lib.AggregateCollection([], collections: [storybook.images, storybook.videos, storybook.sounds])
    assets.storybook = storybook
    @assetLibrarySidebar.setAssets assets


  _showSettings: ->
    App.trackUserAction 'Click app settings'

    view = new App.Views.SettingsContainer(model: App.currentSelection.get('scene'))
    App.modalWithView(view: view).show()


  _showBackgroundSoundForm: ->
    App.trackUserAction 'Click background sound'

    view = new App.Views.BackgroundSoundForm(model: App.currentSelection.get('scene'))
    App.modalWithView(view: view).show()


  _changeScene: (selection, scene) ->
    previousScene = selection.previous('scene')
    @_removeSceneListeners(previousScene)
    @_addSceneListeners(scene)

    App.vent.trigger 'activate:scene', scene
    @vent.trigger 'has_background_sound:scene', scene.hasBackgroundSound()

    @keyframesView.remove() if @keyframesView?
    @keyframesView = new App.Views.KeyframeIndex(collection: scene.keyframes)
    $('#keyframe-list').html @keyframesView.render().el
    scene.fetchKeyframes()

    @newKeyframeView.remove() if @newKeyframeView?
    @newKeyframeView = new App.Views.NewKeyframe(scene: scene)
    $('#keyframe-list').append @newKeyframeView.render().el


  _addSceneListeners: (scene) ->
    if scene?
      scene.widgets.on    'remove', @_checkCurrentWidgetRemoved, @


  _removeSceneListeners: (scene) ->
    if scene?
      scene.widgets.off   'remove', @_checkCurrentWidgetRemoved, @


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


  _addKeyframeListeners: (keyframe) ->
    if keyframe?
      keyframe.widgets.on  'remove', @_checkCurrentWidgetRemoved, @
      keyframe.widgets.on  'reset add remove', keyframe.announceVoiceover, keyframe


  _removeKeyframeListeners: (keyframe) ->
    if keyframe?
      keyframe.widgets.off 'remove', @_checkCurrentWidgetRemoved, @
      keyframe.widgets.off 'reset add remove', keyframe.announceVoiceover, keyframe


  _addNewScene: ->
    App.currentSelection.get('storybook').addNewScene()


  _addNewWidget: (attributes) ->
    containerType = App.Collections.Widgets.containers[attributes.type]
    container = App.currentSelection.get(containerType)
    collection = container.widgets
    widget = collection.model(attributes)

    if widget instanceof App.Models.HotspotWidget and !container.canAddHotspot()
      alert 'Cannot add Hotspots to this scene'
      return

    collection.add widget


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


  initModals: ->
    $('.content-modal').modal(backdrop: true).modal('hide').on('hidden.bs.modal', =>
      @modalView.onHidden()
    )
    $('.lightbox-modal').modal().modal('hide')

    # RFCTR: Should use generic modal view
    $('#storybooks-modal').modal
      backdrop : 'static'
      show     : true
      keyboard : false


  modalWithView: (options) ->
    if options?
      @modalView = new App.Views.Modal _.extend {}, options, el: $('.content-modal')

    @modalView


  lightboxWithView: (view) ->
    if view?
      @lightboxView = new App.Views.Lightbox view, className: 'lightbox-modal'
    @lightboxView


  _playVideo: (videoView) ->
    App.vent.trigger('hide:modal')
    @lightboxWithView(view: videoView).show()


  _showFontLibrary: ->
    view = new App.Views.AssetLibrary(assetType: 'font', assets: App.currentSelection.get('storybook').customFonts())
    App.modalWithView(view: view).show()


  _changeWidget: (selection, widget) ->
    @_triggerCurrentWidgetChangeEvent(selection, widget)


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


  _bringToFront: (sprite) ->
    sprite.collection.setMaxZOrder(sprite)


  _putInBack: (sprite) ->
    sprite.collection.setMinZOrder(sprite)


  showSimulator: =>
    storybook = App.currentSelection.get('storybook')
    json = new App.JSON(storybook).app
    console.log JSON.stringify(json)
    # @simulator ||= new App.Views.Simulator(json: App.storybookJSON.toString())


  initializeMixpanel: ->
    if App.Config.environment == 'production'
      mixpanel.init('bdaad5956eae058c3127a805145c1f6b')
    else
      mixpanel.init('aaef6f73b0358f52df08753974da8f34')

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

    window.onbeforeunload = (event) =>
      return if @syncVent.empty()

      message = "Still saving data, please wait"
      (event || window.event).returnValue = message # Gecko + IE
      message                                       # Webkit-based


  showStorybooks: ->
    view = new App.Views.StorybookIndex
      collection: App.signedInAsUser.storybooks()
      el: '#main'
    view.render()

    view.collection.fetch(reset: true)


  showStorybook: (id) ->
    @initStorybook()
    window.initBuilder()
    $(window).resize -> App.vent.trigger('window:resize')

    (new App.Models.Storybook(id: id)).fetch
      success: (storybook) ->
        App.currentSelection.set storybook: storybook

  setCurrentUser: (user_id) ->
    @currentUser = new App.Models.User(id: user_id)
    @currentUser.fetch(async: false)
    @setMixpanelUserProfile()


  setSignedInAsUser: (user_id) ->
    @signedInAsUser = new App.Models.SignedInAsUser(id: user_id)
    @signedInAsUser.fetch(async: false)


  useMixpanel: ->
    App.Config.environment != 'development' and App.Config.environment != 'test'


  trackUserAction: ->
    if @useMixpanel()
      mixpanel.track arguments...
    else
      # console.log 'track', arguments


  setMixpanelUserProfile: ->
    return unless @useMixpanel()

    mixpanel.identify(@currentUser.get('id'))
    mixpanel.people.set
      "$email": @currentUser.get('email')
      "Company": @currentUser.get('company') || "n/a"
      "$name": @currentUser.get('name') || "n/a"
