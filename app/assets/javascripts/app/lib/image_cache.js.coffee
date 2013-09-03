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
    @proxy.bind 'message', @fromProxy


  get: (url) ->
    unless @cache[url]?
      @cache[url] = $.Deferred()
      @_load(url)

    @cache[url].promise()


  _load: (url) ->
    if @isRelative(url)
      @storeImage url, url
    else
      @loadViaProxy(url)


  loadViaProxy: (url) ->
    @proxy.send
      action: 'load'
      path:   url


  fromProxy: (message) =>
    if message.action == 'loaded'
      @storeImage message.path, message.bits


  storeImage: (url, src) ->
    image = new Image
    image.onload = =>
      @cache[url].resolve(url, image)
    image.src = src


  isRelative: (url) ->
    url.indexOf('/') == 0
