#= require ../assets/sprites/index

App.Views.Storybooks ?= {}

class App.Views.Storybooks.AppIcons extends App.Views.SpriteIndex
  template: JST['app/templates/storybooks/app_icons']

  events:
    'click .image-row'               : 'setActiveImage'
    'click .use-image'               : 'setAppIcon'


  initialize: ->
    @storybook = @options.storybook
    @collection = @storybook.images
    super

  setAppIcon: ->
    $('.use-image').addClass('disabled')
    @storybook.setIcon(@image.id, @appIconSet)


  appIconSet: =>
    App.vent.trigger('hide:modal')
