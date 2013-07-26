#
# The available assets.
#
class App.Views.AssetsLibrary extends Backbone.View
  template: JST['app/templates/assets/library/index']
  tagName: 'ul'
  className: 'assets'
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

    @collection.on 'add',    @_add,    @
    @collection.on 'remove', @_remove, @
    @collection.on 'sort',   @_sort,   @

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


  nameAscendingComparator: (a1, a2) ->
    if a1.get('name') > a2.get('name') then 1 else -1


  nameDescendingComparator: (a1, a2) ->
    if a1.get('name') < a2.get('name') then 1 else -1


  _add: (asset) =>
    klass = if asset instanceof App.Models.Sound
      App.Views.AssetLibrarySound
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
    view = _.find @views, (view) -> view.model == asset
    view.remove()
    @views.splice(@views.indexOf(view), 1)
    @_noAssetsMessage().show() if @collection.length == 0


  _sort: ->
    @collection.each (asset) =>
      view = _.find @views, (view) -> view.model == asset
      @$el.append view.el


  _noAssetsMessage: ->
    @_message ||= @$el.find('.no-assets')


  uploadRequested: ->
    @trigger 'upload'
