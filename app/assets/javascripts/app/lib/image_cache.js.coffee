class App.Lib.ImageCache
  _instance = undefined

  @instance: ->
    unless _instance?
      _instance = new App.Lib._ImageCache()
      _.extend(_instance, Backbone.Events)

    _instance

class App.Lib._ImageCache

  constructor: ->
    @cache = {}
    @proxy = App.Lib.RemoteDomainProxy.instance()
    @proxy.bind 'message', @from_proxy


  get: (url) ->
    @load(url) unless @cache[url]?
    @cache[url].promise()


  load: (url) ->
    @proxy.send
      action: 'load'
      path:   url
    @cache[url] = $.Deferred()


  from_proxy: (message) =>
    if message.action == 'loaded'
      image = new Image
      image.onload = =>
        @cache[message.path].resolve(message.path, image)
      image.src = message.bits
