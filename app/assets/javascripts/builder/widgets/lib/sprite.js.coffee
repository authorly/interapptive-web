class App.Builder.Widgets.Lib.Sprite extends cc.Sprite

  constructor: (options = {}) ->
    super

    throw new Error("Can not create a App.Builder.Widgets.Lib.Sprite without a url")      unless options.url?
    throw new Error("Can not create a App.Builder.Widgets.Lib.Sprite without a filename") unless options.filename?

    @url      = options.url
    @filename = options.filename
    @zOrder   = options.zOrder || 1
    @border   = false
