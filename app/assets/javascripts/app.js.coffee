window.App =
  Models: {}
  Views: {}
  Collections: {}
  Routers: {}

  init: ->
    @scenesCollection = new App.Collections.ScenesCollection []
    @keyframesCollection = new App.Collections.KeyframesCollection []
    @imagesCollection = new App.Collections.ImagesCollection []

    @sceneList(new App.Views.SceneIndex collection: @scenesCollection)
    @keyframeList(new App.Views.KeyframeIndex collection: @keyframesCollection)
    @imageList(new App.Views.ImageIndex(collection: @imagesCollection, tagName: "div"))

    @fileMenu = new App.Views.FileMenuView el: $('#file-menu')
    @toolbar = new App.Views.ToolbarView el: $('#toolbar')
    @contentModal = new App.Views.Modal className: "content-modal"
    @storybooksRouter = new App.Routers.StorybooksRouter
    Backbone.history.start()

  modalWithView: (view) ->
    if view then @view = new App.Views.Modal(view, className: "content-modal") else @view

  currentUser: (user) ->
    if user then @user = new App.Models.User(user) else @user

  currentStorybook: (storybook) ->
    if storybook

      # FIXME Need to remove events from old object
      @storybookJSON = new App.StorybookJSON

      @scenesCollection.on('reset', (scenes) =>
        scenes.each (scene) =>
          @storybookJSON.resetPages()
          @storybookJSON.createPage(scene)
      )
      @scenesCollection.on('add', (scene) =>
        @storybookJSON.createPage(scene)
      )

      @keyframesCollection.on('reset', (keyframes) =>
        scene = @currentScene()

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

  sceneList: (list) ->
    if list then @sceneListView = list else @sceneListView

  keyframeList: (list) ->
    if list then @keyframeListView = list else @keyframeListView

  imageList: (list) ->
    if list then @imageListView = list else @imageListView

  toggleFooter: ->
    $("footer").animate
      height: "toggle"
      opacity: "toggle"
      , "slow"

  # TODO: Refactor me
  capitalizeWord: (word) ->
    word.charAt(0).toUpperCase() + word.slice 1

$ ->
  App.init()

  $('#export').on 'click', ->
    alert(App.storybookJSON)


  $(".content-modal").modal(backdrop: true).modal "hide"
  $("#storybooks-modal").modal(backdrop: "static", show: true, keyboard: false)

  toolbar_modal = $("#modal")
  toolbar_modal.modal(backdrop: true).modal "hide"
  toolbar_modal.bind "hidden", ->
    $("ul#toolbar li ul li").removeClass "active"

  $("ul#toolbar li ul li").click ->
    toolbar_modal.modal "hide"
    unless $(this).is('.scene, .keyframe, .edit-text, .disabled, .images, .videos, .sounds, .fonts, .add-image')
      toolbar_modal.modal "show"
      $("ul#toolbar li ul li").not(this).removeClass "active"
      $(this).toggleClass "active"

  $(window).load ->
    $("#scene-list").css height: ($(window).height()) + "px"

  $(window).resize ->
    $("#scene-list").css height: ($(window).height()) + "px"
    $(".scene-list").css height: ($(window).height()) + "px"
