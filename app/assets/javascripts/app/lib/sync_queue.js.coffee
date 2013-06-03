class App.Lib.SyncQueue

  constructor: (attributes) ->
    @name = attributes.name if attributes.name?
    @vent = attributes.vent if attributes.vent?

    @_queue = $({})


  enqueue: (func) ->
    @vent?.trigger 'synchronization:start', @ if @empty()
    @_queue.queue(func)


  dequeue: ->
    @_queue.dequeue()
    @vent?.trigger 'synchronization:end', @ if @empty()


  empty: ->
    @_queue.queue().length == 0
