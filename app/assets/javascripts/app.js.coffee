window.App =
  Models: {}
  Views: {}
  Collections: {}
  Routers: {}

  init: ->
    # Preparation
    scenesCollection = new App.Collections.ScenesCollection []
    keyframesCollection = new App.Collections.KeyframesCollection []
    @storybooksRouter = new App.Routers.StorybooksRouter

    # Initialize the views!
    #  RE: Initialize the views!
    #  But I wanna scatter them everywhere! ;) Ty.
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

  # Commonly used selectors
  toolbarItem = $("ul#toolbar li ul li")
  modals = $("#modal") # Toolbar modals
  storybooks_modal = $("#storybooks-modal")
  storybook_settings_modal = $(".content-modal")
  scene_settings_modal = $("#scene-settings-modal")

  # Init different modals
  modals.modal(backdrop: true).modal "hide"
  storybook_settings_modal.modal(backdrop: true).modal "hide"
  scene_settings_modal.modal(backdrop: true).modal "hide"
  storybooks_modal.modal(backdrop: "static", show: true, keyboard: false)

  # Remove active style from toolbar items upon modal close
  modals.bind "hidden", ->
    toolbarItem.removeClass "active"

  # Toolbar styling and toggling modals
  toolbarItem.click ->
    modals.modal "hide"
    
    t = $(this)
    unless t.hasClass("scene") or t.hasClass("keyframe") or t.hasClass("edit-text") or t.hasClass("disabled")
      modals.modal "show"
      $("ul#toolbar li ul li").not(this).removeClass "active"
      $(this).toggleClass "active"

  # FIXME, this is slightly quirky but it is bound to change before release.
  # Low priotity.. C.W.
  # Dynamic sidebar height patch for draggable div
  $(window).load ->
    $("#scene-list").css height: ($(window).height()) + "px"
  $(window).resize ->
    $("#scene-list").css height: ($(window).height()) + "px"
    $(".scene-list").css height: ($(window).height()) + "px"
