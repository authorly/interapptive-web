#= require ../assets/sprites/index

App.Views.Storybooks ?= {}

class App.Views.Storybooks.AppIcons extends Backbone.View
  template: JST['app/templates/storybooks/app_icons']

  events:
    'click .use-image' : 'setAppIcon'

  initialize: ->
    @storybook = @options.storybook
    super


  render: ->
    @$el.html @template()

    @view = new App.Views.ImageSelector
      collection: @storybook.images
      el: @$('.images')
    @view.on 'select', @imageSelected, @
    @view.render()

    @


  imageSelected: (image) ->
    @image = image
    @$('.use-image').removeClass('disabled')


  setAppIcon: ->
    return unless @image?

    @storybook.setIcon @image.id
    App.vent.trigger('hide:modal')
