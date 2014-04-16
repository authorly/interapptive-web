class Sim.Views.Sprite

  constructor: (model, callback) ->
    @model = model
    @callback = callback


  load: ->
    cache = cc.TextureCache.getInstance()
    cache.addImageAsync @model.url, @, =>
      @callback(@model, cache.textureForKey(@model.url))
