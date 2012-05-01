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
    
  # Commonly used selectors
  toolbarItem = $("ul#toolbar li ul li")
  modals = $("#myModal") # Toolbar modals
  storybooksModal = $("#myStorybooksModal")

  # Init different modals
  modals.modal(backdrop: true).modal "hide"
  storybooksModal.modal(backdrop: "static", show: true, keyboard: false)
  
  # Hide navbar for storybooks list modals
  $(".navbar").addClass "zero-z-index"

  # Remove active style from toolbar items upon modal close
  modals.bind "hidden", ->
    toolbarItem.removeClass "active"

  # Toolbar stying and toggling modals
  toolbarItem.click ->
    modals.modal "hide"
    
    t = $(this)
    unless t.hasClass("scene") or t.hasClass("keyframe") or t.hasClass("edit-text") or t.hasClass("disabled")
      modals.modal "show"
      $("ul#toolbar li ul li").not(this).removeClass "active"
      $(this).toggleClass "active"
