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
      el: @$('.image-selector')
      image: new App.Models.Image(url: @storybook.get('icon')?.url)
    @view.on 'select', @imageSelected, @
    @view.render()

    @


  imageSelected: (image) ->
    @image = image
    @$('.use-image').removeClass('disabled')


  setAppIcon: ->
    return unless @image?

    App.vent.trigger('hide:modal')
    @storybook.save
      image_id: @image.id
