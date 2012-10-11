class App.Lib.RemoteDomainProxy
  _instance = undefined

  @instance: ->
    unless _instance?
      _instance = new App.Lib._RemoteDomainProxy()
      _.extend(_instance, Backbone.Events)

    _instance


class App.Lib._RemoteDomainProxy
  constructor: () ->
    window.addEventListener 'message', @on_message, false

    @load App.Config.remote_domain_proxy_url


  load: (url) ->
    @remote_domain = url.match(/https:\/\/[^/]+/)[0]

    loader = document.createElement 'iframe'
    loader.setAttribute 'style', 'display:none'
    loader.src = "#{url}?stamp=#{@timestamp()}" # force the browser to download the file and execute the JS
    document.body.appendChild loader


  is_loaded: ->
    !!@end_point


  on_message: (event) =>
    return unless event.origin == @remote_domain

    message = JSON.parse event.data
    switch message.action
      when 'init'
        @end_point = event.source
      else
        @trigger 'message', message


  send: (message) ->
    if @is_loaded()
      @end_point.postMessage JSON.stringify(message), @remote_domain
    else
      window.setTimeout ( => @send message), 200


  timestamp: ->
    (Math.random() + "").substr(-10)

