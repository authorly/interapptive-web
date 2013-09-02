##
# A view that shows an image or a text indicating that no image is selected.
# It also allows removing the image.

class App.Views.SelectedImage extends Backbone.View
  template: JST['app/templates/assets/images/selected_image']
  events:
    'click .delete': 'removeImage'

  initialize: (options) ->
    @image = options.image
    @default = options.default


  render: ->
    @$el.html @template
      url: @image?.get('url')
      removable: @image != @default
    @


  removeImage: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @trigger 'remove'


  setImage: (image) ->
    if image != @image
      @image = image
      @render()
