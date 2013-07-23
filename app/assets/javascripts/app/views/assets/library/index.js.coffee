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
    @_renderElements()
    # TODO just add and/remove the corresponding view
    @collection.on('add remove', @_reRender, @)


  _reRender: ->
    @_removElements()
    @_renderElements()


  _removeElements: ->
    if @views.length > 0
      view.remove() for view in @views
      @views = []


  _renderElements: ->
    if @collection.length > 0
      @collection.each @_renderElement
      @_noAssetsMessage().hide()
    else
      @_noAssetsMessage().show()


  _comparator: (asset) ->
    asset.get('name')


  _renderElement: (asset) =>
    view = new App.Views.AssetLibraryElement(model: asset)
    @views.push(view)
    @$el.append(view.render().el)


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
