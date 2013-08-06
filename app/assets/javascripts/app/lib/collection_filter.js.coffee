class App.Lib.CollectionFilter

  constructor: (options={}) ->
    @value = null
    @criterion = options.criterion
    @setCollection options.collection


  setCollection: (collection) ->
    @collection = collection
    @collection?.on 'add', @filterOne, @

    @filter()


  setValue: (value) ->
    return if @value == value

    @value = value
    @filter()


  filter: ->
    @collection?.each @filterOne


  filterOne: (model) =>
      model.trigger "filter", model, @collection, @criterion.call(@, model)
