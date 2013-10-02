##
# A view that displays a collection of assets as a list.
# It allows filtering and searching through the collection.
#
class App.Views.AssetLibrarySidebar extends Backbone.View
  template: JST['app/templates/assets/library_sidebar']
  events:
    'change #asset-sorting select':   'sortingChanged'
    'click #toggle-assets-view .btn': 'toggleViewClicked'


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
    @thumbsView = new App.Views.AssetsLibrary(el: @$('#asset-list-thumb-view'))
    @thumbsView.on 'upload', (-> @uploader.showUploadUI()), @
    @thumbsView.render()

    @detailsView = new App.Views.AssetsLibrary
      el: @$('#asset-list-table tbody')
      assetOptions:
        tagName: 'tr'
        className: 'js-draggable'
        templateName: 'app/templates/assets/library/asset-details'

    @detailsView.on 'upload', (-> @uploader.showUploadUI()), @
    @detailsView.render()

    # filter by kind
    @filter = new App.Views.AssetFilter
      el: @$('#asset-type-filter')
    @filter.on 'filter', (filter) =>
      @thumbsView. filterBy(filter)
      @detailsView.filterBy(filter)
    @filter.setup()

    # filter by name
    @nameFilter = new App.Views.AssetNameFilter
      el: @$('#asset-text-search')

    # initial sort
    @sortingChanged()

    # set the right toggle
    @toggleListView @$('#toggle-assets-view .btn.disabled').siblings().first()


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
    @collection = assets
    @setComparator(@comparator)

    @thumbsView. setCollection assets
    @detailsView.setCollection assets
    @nameFilter. setCollection assets

    @storybook = assets.storybook
    @uploader.setStorybook @storybook



  setComparator: (comparator) ->
    @comparator = comparator

    if @collection?
      @collection.comparator = @comparator
      @collection.sort() if @comparator?


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
    selected = @$('#asset-sorting select').val()

    mixpanel.track "Sorted assets"

    _s = App.Lib.StringHelper
    comparatorName = _s.decapitalize(_s.camelize(selected)) + 'Comparator'
    @setComparator(@[comparatorName])


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
      mixpanel.track "Uploaded a file", type: type

    @currentUploads.collection.remove @uploader.getData(response).id


  _uploaderFileFailed: (response) ->
    mixpanel.track "Upload failed"
    @currentUploads.collection.remove @uploader.getData(response).id


  toggleViewClicked: (event) ->
    el = $(event.currentTarget)
    @toggleListView(el) unless el.hasClass('disabled')


  toggleListView: (toggleEl) ->
    toggleEl.addClass('disabled').siblings().removeClass('disabled')

    if toggleEl.hasClass 'thumbs'
      @thumbsView.$el.hide()
      @detailsView.$el.show()
      mixpanel.track 'Click asset list view'
    else if toggleEl.hasClass 'list'
      @detailsView.$el.hide()
      @thumbsView.$el.show()
      mixpanel.track 'Click asset thumb view'


  nameAscendingComparator: (a1, a2) ->
    if a1.get('name').toLowerCase() > a2.get('name').toLowerCase() then 1 else -1


  nameDescendingComparator: (a1, a2) ->
    if a1.get('name').toLowerCase() < a2.get('name').toLowerCase() then 1 else -1



