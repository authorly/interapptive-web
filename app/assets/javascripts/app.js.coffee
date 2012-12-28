window.App =

  Models:      {}
  Views:       {}
  Collections: {}
  Routers:     {}
  Lib:         {}
  Config:      {}
  Services:    {}
  Dispatchers: {}

  init: ->
    # A global vent object that allows decoupled communication between
    # different parts of the application. For example, the content of the
    # main view and the buttons in the toolbar.
    # It would be great to use it to decouple more.
    @vent = _.extend {}, Backbone.Events
    # @vent.on 'all', -> console.log arguments # debug everything going through the vent

    @scenesCollection        =   new App.Collections.ScenesCollection        []
    @keyframesCollection     =   new App.Collections.KeyframesCollection     []
    @imagesCollection        =   new App.Collections.ImagesCollection        []
    @fontsCollection         =   new App.Collections.FontsCollection         []
    @soundsCollection        =   new App.Collections.SoundsCollection        []
    @keyframesTextCollection =   new App.Collections.KeyframeTextsCollection []
    @activeActionsCollection =   new App.Collections.ActionsCollection       []

    @contentModal =   new App.Views.Modal className: 'content-modal'
    @fileMenu     =   new App.Views.FileMenuView el: $('#file-menu')
    @toolbar      =   new App.Views.ToolbarView  el: $('#toolbar')

    @sceneList         new App.Views.SceneIndex        collection: @scenesCollection
    @keyframeList      new App.Views.KeyframeIndex     collection: @keyframesCollection
    @keyframeTextList  new App.Views.KeyframeTextIndex collection: @keyframesTextCollection, el: $('#canvas-wrapper')

    @activeSpritesList = new App.Views.ActiveSpritesList()
    # Rename to palette   V
    @activeSpritesWindow @activeSpritesList

    @spriteForm = new App.Views.SpriteForm el: $('#sprite-editor')
    # Rename to palette   V
    @spriteFormWindow @spriteForm

    # @activeActionsWindow(new App.Views.ActiveActionsList collection: @activeActionsCollection)

    @storybooksRouter = new App.Routers.StorybooksRouter
    Backbone.history.start()


  # RFCTR: Comment out
  activeActionsWindow: (view) ->
    if view
      @actionsWindow = new App.Views.WidgetWindow(
        view: view,
        el: $('#active-actions-window'),
        alsoResize: '#active-actions'
      )
    else
      @actionsWindow


  # RFCTR: Rename to palette
  activeSpritesWindow: (view) ->
    if view
      @spritesWindow = new App.Views.WidgetWindow(
        view:       view,
        el:         $('#active-sprites-window'),
        alsoResize: '#active-sprites-window ul li span',
        title:      "Scene Images"
      )
    else
      @spritesWindow


  # RFCTR: Rename to palette
  spriteFormWindow: (view) ->
    if view
      @selectedSpriteWin = new App.Views.WidgetWindow(
        view:      view,
        el:        $('#sprite-form-window'),
        resizable: false
      )
    else
      @selectedSpriteWin


  showSimulator: ->
    @simulator = new App.Views.Simulator(json: App.storybookJSON.toString())

    @openLargeModal(@simulator)


  # RFCTR: Use generic modal & add sizing options to it
  openLargeModal: (view, className='') ->
    return unless view
    @closeLargeModal(false)

    @_modal = new App.Views.LargeModal(view: view, className: 'large-modal')
    $('body').append(@_modal.render().el)
    $('.large-modal').modal(backdrop: true)


  # RFCTR
  closeLargeModal: (animate=true) ->
    return unless @_modal

    @_modal.hide()


  modalWithView: (view) ->
    if view then @view = new App.Views.Modal(view, className: 'content-modal') else @view


  lightboxWithView: (view) ->
    if view then @lightboxView = new App.Views.Lightbox(view, className: 'lightbox-modal') else @lightboxView


  currentUser: (user) ->
    if user then @user = new App.Models.User(user) else @user


  currentStorybook: (storybook) ->
    if storybook

      # FIXME Need to remove events from old object
      @storybookJSON = new App.StorybookJSON

      @scenesCollection.on('reset', (scenes) =>
        @storybookJSON.resetPages()
        scenes.each (scene) =>
          @storybookJSON.createPage(scene)
      )

      @scenesCollection.on('add', (scene) =>
        @storybookJSON.createPage(scene)
      )

      @scenesCollection.on('remove', (scene) =>
        @storybookJSON.destroyPage(scene)
      )

      @keyframesCollection.on('reset', (keyframes) =>
        scene = @currentScene()

        if keyframes? && keyframes.length > 0
          scene.setPreviewFrom keyframes.at(0)

        @storybookJSON.resetParagraphs(scene)
        keyframes.each (keyframe) =>
          @storybookJSON.createParagraph(scene, keyframe)
      )

      @keyframesCollection.on('add', (keyframe) =>
        scene = @currentScene()
        @storybookJSON.createParagraph(scene, keyframe)
      )

      @keyframesCollection.on('remove', (keyframe) =>
        scene = @currentScene()
        @storybookJSON.removeParagraph(scene, keyframe)
      )

      @storybook = storybook

    @storybook


  currentScene: (scene) ->
    if scene
      @scene = scene

      if $('#keyframe-list ul').length == 0
         $('#keyframe-list').html("").html(App.keyframeList().el)

      App.keyframeList().collection.scene_id = scene.get("id")
      App.keyframeList().collection.fetch()

    @scene


  currentKeyframe: (keyframe) ->
    if keyframe
      @keyframe = keyframe
      App.vent.trigger 'keyframe:can_add_text', keyframe.canAddText()
    else
      @keyframe


  currentKeyframeText: (keyframeText) ->
    if keyframeText then @keyframeText = keyframeText else @keyframeText


  sceneList: (list) ->
    if list then @sceneListView = list else @sceneListView


  keyframeList: (list) ->
    if list then @keyframeListView = list else @keyframeListView


  keyframeTextList: (list) ->
    if list then @keyframeTextListView = list else @keyframeTextListView


  selectedText: (textWidget) ->
    if textWidget then @textWidget = textWidget else @textWidget


  # RFCTR
  editTextWidget: (textWidget) ->
    @selectedText(textWidget)
    @fontToolbar.attachToTextWidget(textWidget)
    @keyframeTextList().editText(textWidget)
    App.currentKeyframeText(textWidget.model)


  # RFCTR
  fontToolbarUpdate: (fontToolbar) ->
    @selectedText().fontToolbarUpdate(fontToolbar)


  # RFCTR
  initializeFontToolbar: ->
    App.fontToolbar = new App.Views.FontToolbar(el: $('#font_toolbar'))


  # RFCTR
  fontToolbarClosed: ->
    $('.text-widget').focusout()


  # RFCTR
  updateKeyframeText: ->
    @keyframeTextList().updateText()


  pauseVideos: ->
    $('.video-player')[0].pause()
    $('.content-modal').show()

$ ->
  App.init()

  $('.content-modal').modal(backdrop: true).modal 'hide'
  $('.lightbox-modal').modal().modal("hide").on('hide', App.pauseVideos)
  $('#storybooks-modal').modal(backdrop: 'static', show: true, keyboard: false)

  toolbar_modal = $('#modal')
  toolbar_modal.modal(backdrop: true).modal 'hide'
  toolbar_modal.bind 'hidden', ->
    $("ul#toolbar li ul li").removeClass 'active'

  # Needs ventilation
  $('ul#toolbar li ul li').click ->
    toolbar_modal.modal "hide"

    excluded =
      '.actions, .scene, .keyframe, .animation-keyframe, .edit-text, .disabled, .images,' +
      '.videos, .sounds, .fonts, .add-image, .sync-audio, .touch-zones, .preview, .scene-options'
    unless $(this).is excluded
      $("ul#toolbar li ul li").not(this).removeClass "active"
      $(this).toggleClass "active"
      toolbar_modal.modal "show"

  $(window).resize -> App.vent.trigger('window:resize')
