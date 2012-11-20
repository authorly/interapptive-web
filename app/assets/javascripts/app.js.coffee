window.App =

  Models:      {}
  Views:       {}
  Collections: {}
  Routers:     {}
  Lib:         {}
  Config:      {}

  init: ->
    @scenesCollection =        new App.Collections.ScenesCollection        []
    @keyframesCollection =     new App.Collections.KeyframesCollection     []
    @imagesCollection =        new App.Collections.ImagesCollection        []
    @keyframesTextCollection = new App.Collections.KeyframeTextsCollection []
    @activeActionsCollection = new App.Collections.ActionsCollection       []

    @sceneList         new App.Views.SceneIndex        collection: @scenesCollection
    @keyframeList      new App.Views.KeyframeIndex     collection: @keyframesCollection
    @keyframeTextList  new App.Views.KeyframeTextIndex collection: @keyframesTextCollection, el: $('body')

    @contentModal =   new App.Views.Modal className: 'content-modal'
    @fileMenu =       new App.Views.FileMenuView el: $('#file-menu')
    @toolbar =        new App.Views.ToolbarView  el: $('#toolbar')
    @fontToolbar =    new App.Views.FontToolbar  el: $('#font_toolbar')

    @activeSpritesList = new App.Views.ActiveSpritesList()
    @activeSpritesWindow(@activeSpritesList)

    @spriteForm = new App.Views.SpriteForm el: $('#sprite-editor')
    @spriteFormWindow(@spriteForm)

    @activeActionsWindow(new App.Views.ActiveActionsList collection: @activeActionsCollection)

    @storybooksRouter = new App.Routers.StorybooksRouter
    Backbone.history.start()

  activeActionsWindow: (view) ->
    if view
      @actionsWindow = new App.Views.WidgetWindow(
        view: view,
        el: $('#active-actions-window'),
        alsoResize: '#active-actions'
      )
    else
      @actionsWindow

  activeSpritesWindow: (view) ->
    if view
      @spritesWindow = new App.Views.WidgetWindow(
        view:       view,
        el:         $('#active-sprites-window'),
        alsoResize: '#active-sprites-window ul li span'
      )
    else
      @spritesWindow

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

  #
  # TODO:
  #    Refactor with  App.Views.Modal when it gets options like width/height added to it
  #
  openLargeModal: (view, className='') ->
    return unless view
    @closeLargeModal(false)

    @_modal = new App.Views.LargeModal(view: view)
    $('body').append(@_modal.render().el)

  #
  # TODO:
  #    Refactor with App.Views.Modal when it gets options like width/height added to it
  #
  closeLargeModal: (animate=true) ->
    return unless @_modal

    @_modal.remove()

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
        scenes.each (scene) =>
          #@storybookJSON.resetPages()
          @storybookJSON.createPage(scene)
      )

      @scenesCollection.on('add', (scene) =>
        @storybookJSON.createPage(scene)
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

      @storybook = storybook
    else
      @storybook


  currentScene: (scene) ->
    if scene then @scene = scene else @scene


  currentKeyframe: (keyframe) ->
    if keyframe then @keyframe = keyframe else @keyframe


  currentKeyframeText: (keyframeText) ->
    if keyframeText then @keyframeText = keyframeText else @keyframeText


  sceneList: (list) ->
    if list then @sceneListView = list else @sceneListView


  keyframeList: (list) ->
    if list then @keyframeListView = list else @keyframeListView


  keyframeTextList: (list) ->
    if list then @keyframeTextListView = list else @keyframeTextListView


  #
  # TODO:
  #    Follow naming conventions i.e., currentTextWidget
  #
  selectedText: (textWidget) ->
    if textWidget then @textWidget = textWidget else @textWidget


  #
  # TODO:
  #    Move to textWidget view and access from global
  #
  editTextWidget: (textWidget) ->
    @selectedText(textWidget)
    @fontToolbar.attachToTextWidget(textWidget)
    @keyframeTextList().editText(textWidget)
    App.currentKeyframeText(textWidget.model)


  #
  # TODO:
  #    Move to fontToolbar view and access from global
  #
  fontToolbarUpdate: (fontToolbar) ->
    @selectedText().fontToolbarUpdate(fontToolbar)


  #
  # TODO:
  #    Move to fontToolbar view and access from global
  #
  fontToolbarClosed: ->
    $('.text-widget').focusout()


  #
  # TODO:
  #    Move to keyframeText view and access from global
  #
  updateKeyframeText: ->
    @keyframeTextList().updateText()

  pauseVideos: ->
    $('.video-player')[0].pause()
    $('.content-modal').show()

$ ->
  App.init()

  $('#export').on 'click', -> alert(App.storybookJSON)

  $(".content-modal").modal(backdrop: true).modal "hide"
  $(".lightbox-modal").modal().modal("hide").on('hide', App.pauseVideos)
  $("#storybooks-modal").modal(backdrop: "static", show: true, keyboard: false)

  toolbar_modal = $("#modal")

  toolbar_modal.modal(backdrop: true).modal "hide"

  toolbar_modal.bind "hidden", ->
    $("ul#toolbar li ul li").removeClass "active"

  $("ul#toolbar li ul li").click ->
    excluded = '.actions, .scene, .keyframe, .edit-text, .disabled, .images, .videos, .sounds, .fonts, .add-image, .touch-zones'

    toolbar_modal.modal "hide"

    unless $(this).is excluded
      $("ul#toolbar li ul li").not(this).removeClass "active"
      $(this).toggleClass "active"
      toolbar_modal.modal "show"

  #
  # TODO:
  #    Move to App.Views.SceneIndex
  #
  $(window).resize ->
    $("#scene-list").css height: ($(window).height()) + "px"
    $(".scene-list").css height: ($(window).height()) + "px"
