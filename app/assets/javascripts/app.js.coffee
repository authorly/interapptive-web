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
    @vent.on 'hide:modal',   @_hideModal, @
    @vent.on 'show:message', @_showToast, @
    $(window).resize => @vent.trigger('window:resize')

    @initializeGlobalSync()

    App.fontdetect = window.fontdetect
    delete window.fontdetect


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

    @vent.on 'show:settingsform',    @_showSettings, @
    @vent.on 'show:publishSettings', @_showPublishSettings, @
    @vent.on 'show:subscriptionPublishSettings', @_showSubscriptionPublishSettings, @
    @vent.on 'publish:subscription', @_publishToSubscription, @
    @vent.on 'show:scenebackgroundsoundform', @_showBackgroundSoundForm, @

    @vent.on 'bring_to_front:sprite', @_bringToFront, @
    @vent.on 'put_in_back:sprite',    @_putInBack,    @

    @vent.on 'play:video', @_playVideo, @

    @vent.on 'show:preview', @showSimulator, @

    @vent.on 'canvas-add:asset', @_assetDropped, @

    @toolbar   = new App.Views.ToolbarView  el: $('#toolbar')

    @fontCache = new App.Views.FontCache
    $('head').append @fontCache.render().el

    @context_menu = new App.Views.ContextMenuContainer el: $('#context-menu-container')

    @assetsSidebar = new App.Views.AssetsSidebar
      el: $('.sidebar.right')
    @assetsSidebar.render()

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

        element = ui.helper
        @_assetDropped
          id:   element.data('id')
          type: element.data('type')


  _openStorybook: (__, storybook) ->
    scenesIndex = new App.Views.SceneIndex(collection: storybook.scenes)
    $('#scene-list').html(scenesIndex.render().el)

    storybook.on 'synchronization-start synchronization-end', (__, synchronizing) =>
      @vent.trigger 'can_edit:storybook', !synchronizing

    storybook.scenes.on 'synchronization-start synchronization-end', (__, synchronizing) =>
      @vent.trigger 'can_add:scene', !synchronizing

    storybook.scenes.on 'reset', (scenes) ->
      # The simulator needs all the information upfront
      keyframeLoaders = scenes.map (scene) ->
        scene.fetchKeyframes()
      $.when(keyframeLoaders...).then( ->
        App.vent.trigger 'can_run:simulator', true
      )

    storybook.fetchCollections()

    @fontCache.setCollection(storybook.fonts)

    @currentSelection.set assets: storybook.assets

  _showSettings: ->
    App.trackUserAction 'Opened app settings'

    view = new App.Views.SettingsContainer(model: App.currentSelection.get('storybook'))
    App.modalWithView(view: view).show()


  _showPublishSettings: ->
    App.trackUserAction 'Opened publishing window'

    view = new App.Views.Publishing(model: App.currentSelection.get('storybook'))
    App.modalWithView(view: view).show()


  _showSubscriptionPublishSettings: ->
    App.trackUserAction 'Opened subscription publishing information window'

    view = new App.Views.SubscriptionPublishingInformation
      model: App.currentSelection.get('storybook')
    App.modalWithView(view: view).show()


  _publishToSubscription: ->
    storybook = App.currentSelection.get('storybook')

    if storybook.canBePublishedToSubscription()
      App.vent.trigger 'show:message', 'success', "We are reviewing your storybook for publishing. We will send you an email once it is ready."
      request = App.currentSelection.get('storybook').createSubscriptionPublishRequest()
      request.fail(->
        App.vent.trigger('show:message', 'error', "Something went wrong queueing your application for publication. Please try again.")
      )
    else
      App.vent.trigger 'show:message', 'warning', "Please select a cover for the storybook"
      App.vent.trigger 'show:subscriptionPublishSettings'


  _showBackgroundSoundForm: ->
    App.trackUserAction 'Opened background sound'

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

    # unveil method is provided by jquery.unveil.js
    # Used to lazily load images in the sidebar.
    # See templates/assets/library/asset.jst.hamlc for data-src
    $('#asset-list-thumb-view img').unveil()


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
      App.trackUserAction "Couldn't add hotspot"
      alert 'Cannot add Hotspots to this scene'
      return

    collection.add widget


  # @param [Object] attributes
  # @option attributes [Integer] id
  # @option attributes [String] type ('image', 'sound' or 'video')
  # @option attributes [Object] position {x, y}
  _assetDropped: (attributes={}) ->
    position =
      x: App.Config.dimensions.width / 2
      y: App.Config.dimensions.height / 2

    scene = App.currentSelection.get('scene')

    widgetAttributes =
      position: $.extend {}, position
    widgetAttributes[attributes.type + '_id'] = attributes.id

    switch attributes.type
      when 'image'
        App.trackUserAction 'Added image'
        widgetAttributes.type = 'SpriteWidget'
        widgetAttributes.scale = 1
        break
      when 'sound', 'video'
        App.trackUserAction 'Added hotspot', media_type: attributes.type
        widgetAttributes.type = 'HotspotWidget'
        break

    @_addNewWidget(widgetAttributes)


  initModals: ->
    $('.content-modal').modal(backdrop: true).modal('hide').on('hidden.bs.modal', =>
      @modalView.onHidden()
    )
    $('.simulator-modal').modal(backdrop: true).modal('hide').on('hidden.bs.modal', =>
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
      @modalView = new App.Views.Modal _.extend {}, el: $('.content-modal'), options

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


  showSimulator: ->
    storybook = App.currentSelection.get('storybook')
    @simulator = new App.Views.Simulator
      url:   storybook.simulatorUrl()
      json:  JSON.stringify(storybook.jsonObject())
      fonts: JSON.stringify(storybook.fonts.toJSON())
    App.modalWithView(view: @simulator, el: $('.simulator-modal')).show()


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
    App.trackUserAction "Visited app builder page"

    (new App.Models.Storybook(id: id)).fetch
      success: (storybook) ->
        App.currentSelection.set storybook: storybook


  setCurrentUser: (user_id) ->
    @currentUser = new App.Models.User(id: user_id)
    @currentUser.fetch(async: false)


  setSignedInAsUser: (user_id) ->
    @signedInAsUser = new App.Models.SignedInAsUser(id: user_id)
    @signedInAsUser.fetch(async: false)


  useAnalytics: ->
    App.Config.environment != 'development' and App.Config.environment != 'test'


  trackUserAction: (event_name, data = {}) ->
    if @useAnalytics()
      $.post('/kmetrics.json', {
        km_event: {
          action: 'record',
          name: event_name,
          data: data
        }
      }, 'json')
    else
      # console.log 'track', arguments


  setAnalyticsUserProfile: ->
    return unless @useAnalytics()

    _kmq.push ['identify', @currentUser.get('email')]

