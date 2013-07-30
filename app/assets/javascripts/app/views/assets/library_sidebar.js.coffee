##
# A view that displays a collection of assets as a list.
# It allows filtering and searching through the collection.
#
class App.Views.AssetLibrarySidebar extends Backbone.View
  template: JST['app/templates/assets/library_sidebar']
  events:
    'change #asset-sorting select': 'sortingChanged'

  initialize: ->
    @render()

    @adjustSize()
    @initResizable()

    App.vent.on 'window:resize', @adjustSize, @


  render: ->
    @$el.html(@template())
    @_initializeAssetList()
    @_initializeUploader()

    @


  _initializeAssetList: ->
    # assets
    @assetsView = new App.Views.AssetsLibrary(el: @$('#asset-list'))
    @assetsView.on 'upload', (-> @uploader.showUploadUI()), @
    @assetsView.render()

    # filter by kind
    @filter = new App.Views.AssetFilter
      el: @$('#asset-type-filter')
    @filter.on 'filter', (filter) => @assetsView.filterBy(filter)
    @filter.setup()

    # filter by name
    @nameFilter = new App.Views.AssetNameFilter
      el: @$('#asset-text-search')

    # initial sort
    @sortingChanged()


  _initializeUploader: ->
    # list of assets that are currently being uploaded
    @currentUploads = new App.Views.UploadingAssets
      el: @$('#active-uploads')
      collection: new Backbone.Collection
    @currentUploads.render()

    # uploader
    @uploader = new App.Views.AssetUploader(el: @$('.file-upload'))
    @uploader.on 'add',  @_uploaderFileAdded,    @
    @uploader.on 'done', @_uploaderFileUploaded, @
    @uploader.on 'fail', @_uploaderFileFailed,   @
    @uploader.render()


  setAssets: (assets) ->
    @assetsView.setCollection assets
    @nameFilter.setCollection assets

    @storybook = assets.storybook
    @uploader.setStorybook @storybook


  initResizable: ->
    @$el.parent().resizable
      alsoResize:  '#asset-library-sidebar, #asset-sidebar-sticky-footer, #asset-search-field'
      maxWidth:    500
      minWidth:    320
      handles:     'w'


  adjustSize: ->
    offset = @$el.offset()?.top || 128
    @$el.css height: "#{$(window).height() - offset}px"


  sortingChanged: ->
    comparatorName = @$('#asset-sorting select').val()
    @assetsView.setComparator(comparatorName)


  _uploaderFileAdded: (response) ->
    file = response.files[0]
    return if file.error?

    data = @uploader.getData(response)
    @currentUploads.collection.add
      name: file.name
      size: file.size
      xhr:  data.xhr
      id:   data.id


  _uploaderFileUploaded: (response) ->
    for asset in response.result
      type = asset.type; delete asset.type
      @storybook.addAsset new App.Models[type](asset)

    @currentUploads.collection.remove @uploader.getData(response).id



  _uploaderFileFailed: (response) ->
    @currentUploads.collection.remove @uploader.getData(response).id
