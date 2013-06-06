# A queue for synchronization events.
#
# It accepts a list of objects on which it triggers events
# * when it was empty and a request is enqueued
# * when it becomes empty
class App.Lib.SyncQueue

  constructor: (attributes={}) ->
    @_queue = $({})
    @vents = attributes.vents || []

    @name = attributes.name if attributes.name? # for human-readability


  enqueue: (func) ->
    @_trigger('synchronization:start') if @empty()

    @_queue.queue(func)


  dequeue: ->
    @_queue.dequeue()
    @_trigger('synchronization:end') if @empty()


  empty: ->
    @_queue.queue().length == 0


  _trigger: (event) ->
    vent.trigger(event, @) for vent in @vents
