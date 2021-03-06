##
# A view that displays a collection of assets as a list.
# It allows filtering and searching through the collection.
#
class App.Views.AssetLibrarySidebar extends Backbone.View
  template: JST['app/templates/assets/library_sidebar']
  events:
    'change #asset-sorting select':   'sortingChanged'
    'click #toggle-assets-view .btn': 'toggleViewClicked'
    'click .select-file .btn':        'uploadButtonClicked'


  initialize: ->
    @render()


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

    @detailsContainer = @$('#asset-list-table')
    @detailsView = new App.Views.AssetsLibrary
      el: @detailsContainer.find('tbody')
      assetOptions:
        tagName: 'tr'
        className: 'js-draggable'
        templateName: 'app/templates/assets/library/asset-details'

    @detailsView.on 'upload', (-> @uploader.showUploadUI()), @
    @detailsView.render()

    @instructionsView = new App.Views.AssetsInstructions
      el: @$('#asset-list-instructions')
    @instructionsView.render()

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
    @uploader.on 'fail:global', =>
      @storybook.assets.fetchMissing()
    @uploader.render()


  setAssets: (assets) ->
    @collection = assets
    @setComparator(@comparator)

    @thumbsView.setCollection assets
    @detailsView.setCollection assets
    @instructionsView.setCollection assets
    @nameFilter.setCollection assets

    @storybook = assets.storybook
    @uploader.setStorybook @storybook



  setComparator: (comparator) ->
    @comparator = comparator

    if @collection?
      @collection.comparator = @comparator
      @collection.sort() if @comparator?


  sortingChanged: ->
    selected = @$('#asset-sorting select').val()

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
      # source lets us decide if we should show this image immediately
      # instead of unveiling in case it is being uploaded.
      # See templates/assets/library/asset.jst.hamlc for its use.
      asset.source = 'uploader'
      @collection.add asset

    @currentUploads.collection.remove @uploader.getData(response).id


  _uploaderFileFailed: (response) ->
    @currentUploads.collection.remove @uploader.getData(response).id


  toggleViewClicked: (event) ->
    el = $(event.currentTarget)
    @toggleListView(el) unless el.hasClass('disabled')
    @_revealImages()


  toggleListView: (toggleEl) ->
    toggleEl.addClass('disabled').siblings().removeClass('disabled')

    if toggleEl.hasClass 'thumbs'
      @thumbsView.$el.hide()
      @detailsContainer.show()
      App.trackUserAction 'Viewed files as list'
    else if toggleEl.hasClass 'list'
      @detailsContainer.hide()
      @thumbsView.$el.show()
      App.trackUserAction 'Viewed files as details'


  # Translate the click on the 'add' button to a click on the file input field
  # This hack is needed because the cursor cannot be styled on file input fields
  uploadButtonClicked: (event) ->
    if $(event.target).hasClass('btn')
      @$('#asset-sidebar-sticky-footer input').click()


  nameAscendingComparator: (a1, a2) ->
    if a1.get('name').toLowerCase() > a2.get('name').toLowerCase() then 1 else -1


  nameDescendingComparator: (a1, a2) ->
    if a1.get('name').toLowerCase() < a2.get('name').toLowerCase() then 1 else -1


  _revealImages: ->
    # unveil method is provided by jquery.unveil.js
    # Used to lazily load images in the sidebar.
    # See templates/assets/library/asset.jst.hamlc for data-src
    $('#asset-list-table img').unveil()
    $('#asset-list-thumb-view img').unveil()
