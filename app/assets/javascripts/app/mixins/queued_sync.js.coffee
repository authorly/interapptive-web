App.Mixins.QueuedSync =

  sync: (method, model, options) ->
    @_syncQueue ||= $(name: @.constructor.name)
    deferred = $.Deferred()

    @trigger 'synchronization:start', @ if @_syncQueue.queue().length == 0

    @_syncQueue.queue  =>
      Backbone.sync(method, model, options)
        .done(deferred.resolve)
        .fail(deferred.reject)
        .always =>
          @_syncQueue.dequeue()
          @trigger 'synchronization:end', @ if @_syncQueue.queue().length == 0

    deferred.promise()

