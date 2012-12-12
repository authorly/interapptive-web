#= require ./sprite_widget

##
# A button that has two associated images: one for its default state,
# and one for its tapped/clicked state
#
# It has a name, which shows the purpose of the button.
class App.Builder.Widgets.ButtonWidget extends App.Builder.Widgets.SpriteWidget

  constructor: (options={}) ->
    @_name = options.name
    @_selectedUrl = options.selected_url
    options.url      = "/assets/sprites/#{@_name}.png" unless options.url?
    options.filename =                 "#{@_name}.png" unless options.filename?

    super

    view = new App.Views.ButtonWidgetImagesSelector
      collection: App.imagesCollection
      widget: @
    view.on 'selected', @imagesSelected
    @selector = new App.Views.Modal(view: view)


  doubleClick: =>
    @selector.show()


  imagesSelected: (values) =>
    if @_url != values.baseUrl
      @_url = values.baseUrl
      @trigger('change', 'url')
      # TODO integrate better with the new sprites
      @sprite.url = @_url
      @_getImage()

    if @_selectedUrl != values.tappedUrl
      @_selectedUrl = values.tappedUrl
      @trigger('change', 'selectedUrl')


    @selector.hide()


  toHash: ->
    hash = super
    hash.selected_url = @_selectedUrl
    hash.name = @_name
    hash

