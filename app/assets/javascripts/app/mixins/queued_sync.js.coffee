#
# This mixin changes the sync behavior of a model or collection.
# `sync` requests are enqueued and return a deferred. They are executed
# synchronously, one after another.
App.Mixins.QueuedSync =

  sync: (method, model, options={}) ->
    # `create` uses the collection's sync queue.
    # If the model belongs to a collection, `destroy` uses the collection's
    # sync queue as well.
    if (model instanceof Backbone.Model) and
       (method == 'delete' or method == 'create')
      syncWith = model.collection

    syncQueue = syncWith?.syncQueue() || @syncQueue()
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
