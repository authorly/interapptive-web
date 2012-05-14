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

$ ->
  # Backbone.js initialization
  App.init()

  fileMenuView: new App.Views.FileMenuView
    el: $('#file-menu')

  toolbarView: new App.Views.ToolbarView
    el: $('#toolbar')
    
  # Some selectors
  toolbarItem = $("ul#toolbar li ul li")
  modals = $("#modal") # Toolbar modals
  storybooks_modal = $("#storybooks-modal")
  storybook_settings_modal = $("#storybook-settings-modal")
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