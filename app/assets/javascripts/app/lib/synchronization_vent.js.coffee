#
# A vent for synchronization.
#
# It receives events for synchronization start or end, from different
# objects. It keeps a queue of the objects that are currently under
# synchronization, and triggers events when this queue changes state
# between emtpy and not empty.
class App.Lib.SynchronizationVent

  constructor: ->
    @queue = []
    @on 'synchronization-start', @enqueue, @
    @on 'synchronization-end',   @dequeue, @


  empty: ->
    @queue.length == 0


  enqueue: (src) ->
    # console.log 'started', src.name
    @trigger 'start' if @empty()
    @queue.push src

  dequeue: (src) ->
    # console.log 'ended', src.name
    index = @queue.indexOf(src)
    @queue.splice index, 1
    @trigger 'end' if @empty()


_.extend App.Lib.SynchronizationVent::, Backbone.Events
