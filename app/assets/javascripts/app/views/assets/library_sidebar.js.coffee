##
# A view that displays a collection of assets as a list.
# It allows filtering and searching through the collection.
#
class App.Views.AssetLibrarySidebar extends Backbone.View
  template: JST['app/templates/assets/library_sidebar']
  events:
    'change #asset-sorting select': 'sortingChanged'
    'click #asset-sorting .btn-group a': 'toggleListView'


  initialize: ->
    @render()

    @adjustSize()
    @initResizable()

    App.vent.on 'window:resize', @adjustSize, @

    $('.scene-view-toggle a').live 'click', (event) => @toggleListView(event)


  render: ->
    @$el.html(@template())

    @assetsView = new App.Views.AssetsLibrary(el: @$('#asset-list-thumb-view'))
    @assetsView.on 'upload', (-> @uploader.showUploadUI()), @
    @assetsView.render()

    @filter = new App.Views.AssetFilter
      el: @$('#asset-type-filter')
    @filter.on 'filter', (filter) => @assetsView.filterBy(filter)
    @filter.setup()

    @sortingChanged()

    @currentUploads = new App.Views.UploadingAssets
      el: @$('#active-uploads')
      collection: new Backbone.Collection
    @currentUploads.render()

    @uploader = new App.Views.AssetUploader(el: @$('.file-upload'))
    @uploader.on 'add', (data) =>
      file = data.files[0]
      unless file.error?
        @currentUploads.collection.add
          name: file.name
          size: file.size
          xhr: data.context.data('data').xhr
          id: data.context.data('data').id
    @uploader.on 'done', (data) =>
      _.each data.result, (asset) =>
        type = asset.type; delete asset.type
        @storybook.addAsset new App.Models[type](asset)

      @currentUploads.collection.remove data.context.data('data').id
    @uploader.on 'fail', (data) =>
      @currentUploads.collection.remove data.context.data('data').id

    @uploader.render()

    @


  setAssets: (assets) ->
    @assetsView.setCollection assets
    @storybook = assets.storybook
    @uploader.setStorybook @storybook


  initResizable: ->
    @$el.parent().resizable
      alsoResize:  '#asset-library-sidebar, #asset-sidebar-sticky-footer, #asset-search-field'
      maxWidth:    500
      minWidth:    250
      handles:     'w'


  adjustSize: ->
    offset = @$el.offset()?.top || 128
    @$el.css height: "#{$(window).height() - offset}px"


  sortingChanged: ->
    comparatorName = @$('#asset-sorting select').val()
    @assetsView.setComparator(comparatorName)


  toggleListView: (event) ->
    toggleEl = $(event.currentTarget)
    return if toggleEl.hasClass('disabled')
    toggleEl.addClass('disabled').siblings().removeClass('disabled')

    listViewEl = @$('#asset-list-table')
    thumbViewEl = @$('#asset-list-thumb-view')
    if toggleEl.hasClass 'thumbs'
      thumbViewEl.hide()
      listViewEl.show()
    else if toggleEl.hasClass 'list'
      listViewEl.hide()
      thumbViewEl.show()




