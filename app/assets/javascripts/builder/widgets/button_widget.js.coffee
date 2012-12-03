#= require ./sprite_widget

##
# A button that has two associated images: one for its default state,
# and one for its tapped/clicked state
#
# It has a name, which shows the purpose of the button.
class App.Builder.Widgets.ButtonWidget extends App.Builder.Widgets.SpriteWidget

  constructor: (options={}) ->
    unless options.url?
      options.url = "/assets/sprites/#{options.name}.png"

    super

    @_name = name
    @_selected_url = options.selected_url

    view = new App.Views.ButtonWidgetImagesSelector(widget: @)
    @selector = new App.Views.Modal(view: view)
    @selector.render()


  doubleClick: =>
    @selector.show()
