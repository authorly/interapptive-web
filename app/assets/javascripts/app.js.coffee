window.App =
  Models: {}
  Views: {}
  Collections: {}
  Routers: {}

  init: ->
    scenesCollection = new App.Collections.ScenesCollection []
    keyframesCollection = new App.Collections.KeyframesCollection []
    @storybooksRouter = new App.Routers.StorybooksRouter

    # Initialize views
    @fileMenu = new App.Views.FileMenuView el: $('#file-menu')
    @toolbar = new App.Views.ToolbarView el: $('#toolbar')
    @contentModal = new App.Views.Modal className: "content-modal"
    @sceneList(new App.Views.SceneIndex collection: scenesCollection)
    @keyframeList(new App.Views.KeyframeIndex collection: keyframesCollection)

    Backbone.history.start()

  modalWithView: (modalView) ->
    if modalView
      @modalView = new App.Views.Modal modalView, className: "content-modal"
    else
      return @modalView

  currentUser: (user) ->
    if user
      @user = new App.Models.User(user)
    else
      return @user

  currentStorybook: (storybook) ->
    if storybook
      @storybook = storybook
    else
      return @storybook

  currentScene: (scene) ->
    if scene
      @scene = scene
    else
      return @scene

  currentKeyframe: (keyframe) ->
    if keyframe
      @keyframe = keyframe
    else
      return @keyframe

  sceneList: (list) ->
    if list
      @sceneListView = list
    else
      return @sceneListView

  keyframeList: (list) ->
    if list
      @keyframeListView = list
    else
      return @keyframeListView

$ ->
  # Backbone.js initialization
  App.init()

  $("#image-upload-modal, .content-modal").modal(backdrop: true).modal "hide"
  $("#storybooks-modal").modal(backdrop: "static", show: true, keyboard: false)

  modals = $("#modal") # Toolbar modals
  modals.modal(backdrop: true).modal "hide"

  modals.bind "hidden", ->
    $("ul#toolbar li ul li").removeClass "active"

  $("ul#toolbar li ul li").click ->
    modals.modal "hide"

    unless $(this).is('.scene, .keyframe, .edit-text, .disabled, .images')
      modals.modal "show"
      $("ul#toolbar li ul li").not(this).removeClass "active"
      $(this).toggleClass "active"

  # Resize drag-to-scroll container according to window height
  $(window).load ->
    $("#scene-list").css height: ($(window).height()) + "px"
  $(window).resize ->
    $("#scene-list").css height: ($(window).height()) + "px"
    $(".scene-list").css height: ($(window).height()) + "px"

  # TODO: Move asset upload logic to a backbone view
  $("#fileupload").fileupload()
  $.getJSON $("#fileupload").prop("action"), (files) ->
    fu = $("#fileupload").data("fileupload")
    template = undefined
    fu._adjustMaxNumberOfFiles -files.length
    template = fu._renderDownload(files).prependTo($("#fileupload .files"))
    fu._reflow = fu._transition and template.length and template[0].offsetWidth
    template.addClass "in"
    $("#loading").remove()
