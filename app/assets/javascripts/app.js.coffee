window.App = 
  Models: {}
  Views: {}
  Collections: {}
  Routers: {}

  init: ->
    new App.Routers.StorybooksRouter
    Backbone.history.start()

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

  fileMenuView = new App.Views.FileMenuView
    el: $('#file-menu')
  
  toolbarView = new App.Views.ToolbarView
    el: $('#toolbar')
    
  # Commonly used selectors
  toolbarItem = $("ul#toolbar li ul li")
  modals = $("#modal") # Toolbar modals
  storybooksModal = $("#storybooks-modal")

  # Init different modals
  modals.modal(backdrop: true).modal "hide"
  storybooksModal.modal(backdrop: "static", show: true, keyboard: false)

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
