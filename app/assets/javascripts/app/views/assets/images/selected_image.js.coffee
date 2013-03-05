##
# A view that shows an image or a text indicating that no image is selected.

class App.Views.SelectedImage extends Backbone.View
  template: JST['app/templates/assets/images/selected_image']

  tagName:  'div'


  initialize: (options) ->
    @url = options.url


  render: ->
    @$el.html(@template(url: @url))
    @


  setUrl: (url) ->
    @url = url
    @render()