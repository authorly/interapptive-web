class App.Lib.AggregateCollection extends Backbone.Collection

  constructor: (__, options) ->
    super

    for collection in (options.collections || [])
      collection.on 'all', @collectionEvent, @
      collection.each (model) => @add(model)


  collectionEvent: (event, options...)->
    switch event
      when 'add'    then @add     options[0]; break
      when 'remove' then @remove  options[0]; break
