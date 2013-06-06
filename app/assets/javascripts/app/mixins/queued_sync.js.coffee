#
# This mixin changes the sync behavior of a model or collection.
# `sync` requests are enqueued and return a deferred. They are executed
# synchronously, one after another.
App.Mixins.QueuedSync =

  sync: (method, model, options) ->
    syncQueue = @syncQueue()
    deferred = $.Deferred()

    syncQueue.enqueue  =>
      Backbone.sync(method, model, options)
        .done(deferred.resolve)
        .fail(deferred.reject)
        .always => syncQueue.dequeue()

    deferred.promise()


  syncQueue: ->
    @_syncQueue ||= new App.Lib.SyncQueue
      name: "#{@.constructor.name} #{if @cid? then "##{@cid}" else ''}"
      vents: if @syncVents? then @syncVents() else [@]
