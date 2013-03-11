window.App =

  Models:      {}
  Views:       {}
  Collections: {}
  Routers:     {}
  Lib:         {}
  Config:      {}

  init: ->
    # A global vent object that allows decoupled communication between
    # different parts of the application. For example, the content of the
    # main view and the buttons in the toolbar.
    @vent = _.extend {}, Backbone.Events

    @vent.on 'reset:palettes',           @_resetPalettes,    @
    @vent.on 'toggle:palette',           @_togglePalette,    @
    @vent.on 'initialize:hotspotWidget', @_openHotspotModal, @
    @vent.on 'hide:modal',               @_hideModal,        @

    @vent.on 'create:scene',    @_addNewScene,    @
    @vent.on 'create:keyframe', @_addNewKeyframe, @
    @vent.on 'create:widget',   @_addNewWidget,   @
    @vent.on 'create:image',    @_addNewImage,    @

    @vent.on 'show:sceneform',  @_showSceneForm,  @

    @vent.on 'change:keyframeWidgets',          @_changeKeyframeWidgets, @
    @vent.on 'change:sceneWidgets load:sprite', @_changeSceneWidgets,    @

    @vent.on 'play:video', @_playVideo, @

    @currentSelection = new Backbone.Model
      storybook: null
      scene: null
      keyframe: null
      text_widget: null
    @currentWidgets = new App.Collections.CurrentWidgets(@currentSelection)

    @toolbar   = new App.Views.ToolbarView  el: $('#toolbar')
    @file_menu = new App.Views.FileMenuView el: $('#file-menu')

    @spritesListPalette = new App.Views.PaletteContainer
      view       : new App.Views.SpriteListPalette(collection: @currentWidgets)
      el         : $('#sprite-list-palette')
      title      : 'Scene Images'
      alsoResize : '#sprite-list-palette ul li span'

    @textEditorPalette = new App.Views.PaletteContainer
      title: 'Font Settings'
      view : new App.Views.TextEditorPalette
      el   : $('#text-editor-palette')

    @spriteEditorPalette = new App.Views.PaletteContainer
      view      : new App.Views.SpriteEditorPalette
      el        : $('#sprite-editor-palette')
      resizable : false

    @palettes = [ @textEditorPalette, @spritesListPalette, @spriteEditorPalette ]

    @currentSelection.on 'change:storybook', @_openStorybook, @
    @currentSelection.on 'change:scene',     @_changeScene,   @


  saveCanvasAsPreview: (keyframe) ->
    window.setTimeout ( ->
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

    storybook.scenes.on 'change:widgets', =>
      keyframe = App.currentSelection.get('keyframe')
      @saveCanvasAsPreview(keyframe)

    storybook.fetchCollections()

    @textEditorPalette.view.openStorybook(storybook)


  _showSceneForm: ->
    view = new App.Views.SceneForm(model: App.currentSelection.get('scene'))
    App.modalWithView(view: view).show()


  _changeScene: (__, scene) ->
    App.vent.trigger 'activate:scene', scene
    @keyframesView.remove() if @keyframesView?
    @keyframesView = new App.Views.KeyframeIndex(collection: scene.keyframes)
    $('#keyframe-list').html @keyframesView.render().el
    scene.fetchKeyframes()


  _changeKeyframeWidgets: (keyframe) ->
    return unless App.currentSelection.get('keyframe') == keyframe
    @saveCanvasAsPreview(keyframe)


  _changeSceneWidgets: ->
    keyframe = App.currentSelection.get('keyframe')
    @saveCanvasAsPreview(keyframe)


  _addNewScene: ->
    App.currentSelection.get('storybook').addNewScene()


  _addNewKeyframe: (attributes) ->
    App.currentSelection.get('scene').addNewKeyframe(attributes)


  _addNewWidget: (attributes) ->
    container = App.Collections.Widgets.containers[attributes.type]
    App.currentSelection.get(container).widgets.add(attributes)


  _addNewImage: ->
    scene = App.currentSelection.get('scene')
    view = new App.Views.SpriteIndex(collection: scene.storybook.images)

    imageSelected = (image) ->
      scene.widgets.add
        type: 'SpriteWidget'
        url:      image.get 'url'
        filename: image.get 'name'
      scene.save()

      view.off('select', imageSelected)
      App.vent.trigger('hide:modal')
    view.on 'select', imageSelected
    App.modalWithView(view: view).show()


  _openHotspotModal: (widget) ->
    view = new App.Views.HotspotsIndex(widget: widget, storybook: @currentSelection.get('storybook'))
    @modalWithView(view: view).show()


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
    @modalWithView().hide()


  _changeKeyframe: (__, keyframe) ->
    @currentWidgets.changeKeyframe(keyframe)


  _playVideo: (video_view) ->
    @lightboxWithView(view: video_view).show()


  _triggerLightboxHideEvents: ->
    @lightboxView.view.trigger('pause')


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

