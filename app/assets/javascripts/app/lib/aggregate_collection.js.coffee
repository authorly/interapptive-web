class App.Lib.AggregateCollection extends Backbone.Collection

  constructor: (__, options) ->
    super

    for collection in (options.collections || [])
      collection.on 'all', @collectionEvent, @
      collection.each (model) => @add(model)


  collectionEvent: (event, options...)->
    model = options[0]
    switch event
      when 'add'    then @add    model, fromMember: true; break
      when 'remove' then @remove model; break

