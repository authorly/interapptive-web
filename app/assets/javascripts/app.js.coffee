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
    @vent.on 'show:imageLibrary',        @_showImageLibrary, @
    @vent.on 'show:message',             @_showToast,        @

    @vent.on 'create:scene',    @_addNewScene,    @
    @vent.on 'create:keyframe', @_addNewKeyframe, @
    @vent.on 'create:widget',   @_addNewWidget,   @
    @vent.on 'create:image',    @_addNewImage,    @

    @vent.on 'show:sceneform',  @_showSceneForm,  @

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

    @spriteLibraryPalette = new App.Views.PaletteContainer
      title:     'Image Library'
      view:      new App.Views.SpriteLibraryPalette
      el:        $('#sprite-library-palette')
      resizable: true

    canvas = $('#builder-canvas')
    canvasAttributes =
      height: canvas.height()
      offset: canvas.offset()
      scale:  canvas.attr('height') / canvas.height()
      margins:
        top: 200
        left: 125
    canvas.droppable
      accept: '.sprite-image'
      drop: (__, ui) ->
        offset = canvas.offset()
        App.vent.trigger 'create:image', null,
          id: ui.draggable.data('id')
          position:
            x: (ui.position.left - offset.left - canvasAttributes.margins.left + ui.helper.width() * 0.5) * canvasAttributes.scale
            y: canvasAttributes.height - ((ui.position.top - offset.top - canvasAttributes.margins.top) + ui.helper.height() * 0.5) * canvasAttributes.scale

    @palettes = [ @textEditorPalette, @spritesListPalette, @spriteEditorPalette, @spriteLibraryPalette ]

    @currentSelection.on 'change:storybook', @_openStorybook,  @
    @currentSelection.on 'change:scene',     @_changeScene,    @
    @currentSelection.on 'change:keyframe',  @_changeKeyframe, @


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
      when 'imageEditor' then @spriteEditorPalette
      when 'fontEditor'  then @textEditorPalette
    palette.$el.toggle() if palette?


  _openStorybook: (__, storybook) ->
    scenesIndex = new App.Views.SceneIndex(collection: storybook.scenes)
    $('#scene-list').html(scenesIndex.render().el)

    storybook.scenes.on 'change:widgets', =>
      keyframe = App.currentSelection.get('keyframe')
      @saveCanvasAsPreview()


    storybook.scenes.on 'reset', (scenes) ->
      # The simulator needs all the information upfront
      scenes.each (scene) ->
        scene.fetchKeyframes()

    storybook.fetchCollections()

    @textEditorPalette.view.openStorybook(storybook)
    @spriteLibraryPalette.view.openStorybook(storybook)


  _showSceneForm: ->
    view = new App.Views.SceneForm(model: App.currentSelection.get('scene'))
    App.modalWithView(view: view).show()


  _changeScene: (selection, scene) ->
    previousScene = selection.previous('scene')
    @_removeSceneListeners(previousScene)
    @_addSceneListeners(scene)

    App.vent.trigger 'activate:scene', scene
    scene.announceAnimation()

    @keyframesView.remove() if @keyframesView?
    @keyframesView = new App.Views.KeyframeIndex(collection: scene.keyframes)
    $('#keyframe-list').html @keyframesView.render().el
    scene.fetchKeyframes()


  _addSceneListeners: (scene) ->
    if scene?
      scene.keyframes.on  'reset add remove', scene.announceAnimation, scene


  _removeSceneListeners: (scene) ->
    if scene?
      scene.keyframes.off 'reset add remove', scene.announceAnimation, scene


  _announceAnimation: (scene) ->


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
      keyframe.widgets.on  'reset add remove', keyframe.announceVoiceover, keyframe


  _removeKeyframeListeners: (keyframe) ->
    if keyframe?
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
    container = App.Collections.Widgets.containers[attributes.type]
    App.currentSelection.get(container).widgets.add(attributes)


  _addNewImage: (image, options={}) ->
    scene = App.currentSelection.get('scene')

    spriteOptions = {}
    unless image
      image = scene.storybook.images.get(options.id)
      spriteOptions.position = options.position

    $.extend spriteOptions,
      type: 'SpriteWidget'
      url:  image.get('url')
      filename: image.get('name')

    scene.widgets.add spriteOptions


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


  _playVideo: (video_view) ->
    @lightboxWithView(view: video_view).show()


  _showImageLibrary: ->
    @file_menu.showImageLibrary()


  _showToast: (type, message) ->
    window.toastr[type](message)


  showSimulator: =>
    storybook = App.currentSelection.get('storybook')
    json = new App.JSON(storybook).app
    console.log JSON.stringify(json)
    # @simulator ||= new App.Views.Simulator(json: App.storybookJSON.toString())


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

