#
# The available assets.
#
class App.Views.AssetsLibrary extends Backbone.View
  template: JST['app/templates/assets/library/index']
  events:
    'click .no-assets a': 'uploadRequested'


  initialize: ->
    @views = []


  render: ->
    @$el.html(@template())
    @


  setCollection: (collection) ->
    @collection = collection

    @_setComparator(@comparator)

    @collection.on 'add',    @_add,           @
    @collection.on 'remove', @_remove,        @
    @collection.on 'sort',   @_sort,          @
    @collection.on 'filter', @_assetFiltered, @

    if @collection.length > 0
      @collection.each @_add
    else
      @_noAssetsMessage().show()


  setComparator: (name) ->
    _s = App.Lib.StringHelper
    comparatorName = _s.decapitalize(_s.camelize(name)) + 'Comparator'
    @_setComparator(@[comparatorName])


  _setComparator: (comparator) ->
    @comparator = comparator

    if @collection?
      @collection.comparator = @comparator
      @collection.sort() if @comparator?


  filterBy: (filter) ->
    @$el.removeClass('images videos sounds').addClass(filter)


  _assetFiltered: (asset, __, accepted) ->
    @_getView(asset).$el
      .removeClass('filter-on filter-off')
      .addClass("filter-#{if accepted then 'on' else 'off'}")


  nameAscendingComparator: (a1, a2) ->
    if a1.get('name').toLowerCase() > a2.get('name').toLowerCase() then 1 else -1


  nameDescendingComparator: (a1, a2) ->
    if a1.get('name').toLowerCase() < a2.get('name').toLowerCase() then 1 else -1


  _add: (asset) =>
    klass = if asset instanceof App.Models.Sound
      App.Views.AssetLibrarySound
    else if asset instanceof App.Models.Video
      App.Views.AssetLibraryVideo
    else
      App.Views.AssetLibraryElement

    view = new klass(model: asset)
    viewElement = view.render().el
    @views.push view

    if (index=@collection.indexOf(asset)) == 0
      @$el.prepend viewElement
    else
      @$el.children().eq(index-1).after(viewElement)

    @_noAssetsMessage().hide()


  _remove: (asset) ->
    view = @_getView(asset)
    view.remove()
    @views.splice(@views.indexOf(view), 1)
    @_noAssetsMessage().show() if @collection.length == 0


  _sort: ->
    @collection.each (asset) =>
      view = @_getView(asset)
      @$el.append view.el


  _noAssetsMessage: ->
    @_message ||= @$el.find('.no-assets')


  uploadRequested: ->
    @trigger 'upload'


  _getView: (asset) ->
    _.find @views, (view) -> view.model == asset
