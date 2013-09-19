##
# A view that shows an image or a text indicating that no image is selected.
# It also allows removing the image.

class App.Views.SelectedImage extends Backbone.View
  initialize: (options) ->
    @image = options.image


  render: ->
    @$el.html @template
      url: @image?.get('url')
    @


  setImage: (image) ->
    if image != @image
      @image = image
      @render()
