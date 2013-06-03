App.Mixins.QueuedSync =

  sync: (method, model, options) ->
    @_syncQueue ||= new App.Lib.SyncQueue
      name: @.constructor.name
      vent: @
    deferred = $.Deferred()

    @_syncQueue.enqueue  =>
      Backbone.sync(method, model, options)
        .done(deferred.resolve)
        .fail(deferred.reject)
        .always => @_syncQueue.dequeue()

    deferred.promise()

