#
# The available assets.
#
class App.Views.AssetsLibrary extends Backbone.View
  template: JST['app/templates/assets/library/index']
  tagName: 'ul'
  className: 'assets'
  events:
    'click li': '_highlightElement'
    'click .icon-plus': '_addClicked'


  initialize: ->
    @views = []


  render: ->
    @$el.html(@template())
    @_enableAddTooltip()
    @


  setCollection: (collection) ->
    @collection = collection

    @collection.comparator = @_comparator
    @collection.sort()

    @collection.on 'add',    @_add,    @
    @collection.on 'remove', @_remove, @

    if @collection.length > 0
      @collection.each @_add
      @_noAssetsMessage().hide()
    else
      @_noAssetsMessage().show()


  _comparator: (asset) ->
    asset.get('name')


  _add: (asset) =>
    view = new App.Views.AssetLibraryElement(model: asset)
    viewElement = view.render().el
    @views.push view

    if (index=@collection.indexOf(asset)) == 0
      @$el.prepend viewElement
    else
      @$el.children().eq(index-1).after(viewElement)


  _remove: (asset) ->
    view = _.find @views, (view) -> view.model == asset
    view.remove()
    @views.splice(@views.indexOf(view), 1)


  _openUploadModal: (e) ->
    e.preventDefault()
    App.vent.trigger('show:imageLibrary')


  _noAssetsMessage: ->
    @_message ||= @$el.find('.no-assets')


  _highlightElement: (event) ->
    @$(event.currentTarget).toggleClass('selected').siblings().removeClass('selected')


  _enableAddTooltip: ->
    @$('.icon-plus').tooltip
      title: "Add Images..."
      placement: 'right'


  _addClicked: ->
    App.vent.trigger('show:imageLibrary')
