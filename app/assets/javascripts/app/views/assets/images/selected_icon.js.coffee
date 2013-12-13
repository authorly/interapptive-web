#= require ./selected_image

##
# A view that shows the selected image for iOS application icon.

class App.Views.SelectedIcon extends App.Views.SelectedImage
  template: JST['app/templates/assets/images/selected_icon']

  events:
    'click a': 'removeIconClicked'


  removeIconClicked: (event) ->
    event.preventDefault()

    @trigger 'select', null
