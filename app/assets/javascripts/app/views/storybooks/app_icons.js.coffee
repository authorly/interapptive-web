#= require ../assets/sprites/index

App.Views.Storybooks ?= {}
class App.Views.Storybooks.AppIcons extends App.Views.SpriteIndex
  template: JST["app/templates/storybooks/app_icons"]

  events:
    "click .image-row":               "setActiveImage"
    "touchstart, touchend .zoomable": "doZoom"
    "click .use-image":               "setAppIcon"

  setAppIcon: ->
    $('.use-image').addClass('disabled')

    $.post("/storybooks/#{App.currentStorybook().id}/icon",
      image_id: @image.id,
      ->,
      'json').success(@appIconSet)

  appIconSet: ->
    App.modalWithView().hide()
