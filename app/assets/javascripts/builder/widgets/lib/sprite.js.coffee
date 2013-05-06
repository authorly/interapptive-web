class App.Builder.Widgets.Lib.Sprite extends cc.Sprite

  constructor: (options = {}) ->
    super

    @model = options.model
    @url      = @model.url()
    @filename = @model.filename()
    @zOrder   = @model.get('z_order')
    @border   = false

    throw new Error("Can not create a App.Builder.Widgets.Lib.Sprite without a url")      unless @url?
    throw new Error("Can not create a App.Builder.Widgets.Lib.Sprite without a filename") unless @filename?
