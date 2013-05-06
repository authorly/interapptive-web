##
# A view that shows an image or a text indicating that no image is selected.

class App.Views.SelectedImage extends Backbone.View
  template: JST['app/templates/assets/images/selected_image']

  tagName:  'div'


  initialize: (image) ->
    @image = image


  render: ->
    @$el.html(@template(url: @image?.get('url')))
    @


  setImage: (image) ->
    if image != @image
      @image = image
      @render()
