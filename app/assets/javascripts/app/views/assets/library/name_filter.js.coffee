class App.Views.AssetNameFilter extends Backbone.View
  WAIT_FOR_NO_KEYPRESS_FOR = 200 # ms

  events:
    'change  #asset-search-field': 'filterChanged'
    'keydown #asset-search-field': 'filterChanged'


  initialize: ->
    @_input = @$('#asset-search-field')
    @_filter = new App.Lib.CollectionFilter
      collection: @collection
      criterion: (asset) ->
        if @value?.length > 0
          asset.get('name').toLowerCase().indexOf(@value) > -1
        else
          true
    @filter()



  setCollection: (collection) ->
    @collection = collection
    @_filter.setCollection(@collection)


  filterChanged: ->
    clearTimeout(@keyTimeout)
    @keyTimeout = setTimeout @filter, WAIT_FOR_NO_KEYPRESS_FOR


  filter: =>
    @_filter.setValue $.trim(@_input.val().toLowerCase())
