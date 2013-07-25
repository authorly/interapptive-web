#
# The available assets.
#
class App.Views.AssetsLibrary extends Backbone.View
  template: JST['app/templates/assets/library/index']
  tagName: 'ul'
  className: 'assets'


  initialize: ->
    @views = []


  render: ->
    @$el.html(@template())
    @


  setCollection: (collection) ->
    @collection = collection

    @collection.comparator = @_comparator
    @collection.sort()

    @collection.on 'add',    @_add,    @
    @collection.on 'remove', @_remove, @

    @collection.each @_add


  filterBy: (filter) ->
    @$el.removeClass('images videos sounds').addClass(filter)


  _comparator: (asset) ->
    asset.get('name')


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


  _noAssetsMessage: ->
    @_message ||= @$el.find('.no-assets')

