class App.Views.AssetLibrary extends Backbone.View
  template: JST['app/templates/assets/library']

  events:
    'click .video-thumbnail' : 'playVideo'
    'click .delete':           'destroyAsset'


  initialize: ->
    @assetType = @options.assetType
    @assets = @options.assets
    @acceptedFileTypes = @acceptedFileTypes(@assetType)
    @_addListeners()


  _addListeners: ->
    @assets.on 'add',    @_assetAdded,    @
    @assets.on 'remove', @_assetRemoved,    @

  # _removeListeners: ->


  render: ->
    @$el.html @template(assetType: @assetType, acceptedFileTypes: @acceptedFileTypes, assets: @assets)
    @initUploader()
    @formatFileSize = @fileUpload.data('fileupload')._formatFileSize
    @initAssetsIndex()
    @


  # TODO invoke this when modal is hidden
  # close: ->
    # @$('#fileupload').fileupload 'disable'
    # $('.content-modal').removeClass 'asset-library-modal'
    # @_removeListeners()
  # closeAssetLib: ->
    # @fileUpload.fileupload 'disable'
    # $('.content-modal').removeClass 'asset-library-modal'
    # @assets.off 'reset', @render, @


  initUploader: ->
    # TODO this concern belongs to the parent of the class
    $('.content-modal').addClass 'asset-library-modal'

    @fileUpload = @$('#fileupload').fileupload(
      acceptFileTypes: @fileTypePattern(@assetType)
      uploadTemplate   : JST["app/templates/assets/upload"]
    ).bind('fileuploadchange', (event, data) =>
      @_toggleUploadedAssetsHeader(data.files.length)
    ).bind('fileuploadfail', (event, data) =>
      @_toggleUploadedAssetsHeader(-data.files.length)
    ).bind('fileuploadcompleted', (event, data) =>
      @_toggleUploadedAssetsHeader(-data.files.length)
      @assets.add data.result
    )
    @_toggleUploadedAssetsHeader()


  initAssetsIndex: ->
    fields = @_assetsFields()
    data = @assets.map (asset) ->
      _.map fields, (field) -> asset.get(field)

    columns = [
      { sTitle: 'Name' },
      {
        sTitle: 'Size'
        bSearchable: false
        mRender: (data, operation, row) =>
          if operation == 'display'
            @formatFileSize(data)
          else
            data
      },
      {
        sTitle: 'Date'
        bSearchable: false
        mRender: (data, operation, row) =>
          if operation == 'display'
            App.Lib.DateTimeHelper.timeToHuman(data)
          else
            data
      }
      {
        sTitle: ''
        bSearchable: false
        bSortable: false
        mRender: (data, operation, row) =>
          if operation == 'display'
            "<button class='delete btn btn-warning' data-id='#{data}'>Delete</button>"
          else
            data
      },
    ]
    if @assetType == 'image'
      columns = [{
        sTitle: ''
        bSearchable: false
        bSortable: false
        mRender: (data, operation, row) =>
          if operation == 'display' && @assetType == 'image'
            "<img src='#{data}'/>"
          else
            data
      }].concat(columns)

    @assetsView = @$('.uploaded').dataTable
      aaData: data
      aoColumns: columns
      aaSorting: [[@_assetsFields().indexOf('created_at'), 'asc']]
      bLengthChange: false


  _assetAdded:  (asset) ->
    data = _.map @_assetsFields(), (field) -> asset.get(field)
    @assetsView.fnAddData data


  _assetRemoved:  (asset) ->
    id = asset.id
    row = @assetsView.find(".delete[data-id=#{id}]").closest('tr')[0]
    @assetsView.fnDeleteRow row


  _assetsFields: ->
    unless @_fields?
      @_fields = []
      @_fields.push('thumbnail_url') if @assetType == 'image'
      @_fields = @_fields.concat ['name', 'size', 'created_at']
      @_fields.push 'id'
    @_fields


  fileTypePattern: () ->
    file_types = @acceptedFileTypes
    up_file_types = file_types.map (type) ->
      type.toUpperCase()

    pattern = '\.('
    pattern = pattern + file_types.join('|')
    pattern = pattern + '|'
    pattern = pattern + up_file_types.join('|')
    pattern = pattern + ')$'

    new RegExp(pattern)


  acceptedFileTypes: (assetType) ->
    switch assetType
      when 'image', 'images' then return ['jpg', 'jpeg', 'gif', 'png']
      when 'video', 'videos' then return ['mov', 'mpg', 'mpeg', 'mkv', 'm4v', 'avi', 'flv', 'mp4']
      when 'font',  'fonts'  then return ['ttf']
      when 'sound', 'sounds' then return ['mp3', 'wav', 'aac', 'm4a']


  playVideo: (em) ->
    App.vent.trigger('hide:modal')

    video = $(em.currentTarget).data('video')
    view = new App.Views.VideoPlayer(video)
    App.vent.trigger('play:video', view)


  attachDeleteEvent: ->
    $('.delete-asset').click(@hideRow)


  hideRow: (event) ->
    $(event.target).closest('tr').hide()


  destroyAsset: (e) =>
    e.preventDefault()
    e.stopPropagation()

    if @assetType == 'image'
      return unless confirm("Are you sure you want to delete this image and corresponding sprites from all the scenes?")

    @_destroyAsset(e)


  _destroyAsset: (e) ->
    id = $(e.currentTarget).data('id')
    asset = @assets.get(id)
    asset.destroy
      url: asset.get('delete_url')


  _toggleUploadedAssetsHeader: (delta=0)=>
    nr = @fileUpload.data('fileupload').options.filesContainer.children().length + delta
    uploadableAssets = @fileUpload.find('.toUpload thead')
    if nr > 0
      uploadableAssets.show()
    else
      uploadableAssets.hide()


