class App.Views.AssetLibrary extends Backbone.View
  template: JST['app/templates/assets/library']

  events:
    'click .video-thumbnail' : 'playVideo'


  initialize: ->
    @assetType = @options.assetType
    @assets = @options.assets
    @acceptedFileTypes = @acceptedFileTypes(@assetType)
    @_addListeners()


  _addListeners: ->
    @assets.on 'reset add remove', @loadAndShowFileData, @


  _removeListeners: ->
    # @assets.off 'reset add remove', @loadAndShowFileData, @


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
      singleFileUploads: false
      uploadTemplate   : JST["app/templates/assets/#{@assetType}s/upload"]
      destroy: @_confirmDestroyAsset
    ).bind('fileuploadchange', (event, data) =>
      @_toggleUploadedAssetsHeader(data.files.length)
    ).bind('fileuploadfail', (event, data) =>
      @_toggleUploadedAssetsHeader(-data.files.length)
    ).bind('fileuploaddestroyed',  (event, data) =>
      deleteButton = $(data.context.context)
      id = deleteButton.closest('tr').find('.preview').data('id')
      @assets.remove @assets.get(id)
    ).bind('fileuploadcompleted', (event, data) =>
      @assets.add data.result
    )
    @_toggleUploadedAssetsHeader()


  initAssetsIndex: ->
    fields = if @assetType == 'image' then ['thumbnail_url'] else []
    fields = fields.concat ['name', 'size', 'created_at']
    data = @assets.map (asset) ->
      _.map fields, (field) -> asset.get(field)

    columns = [
      { sTitle: 'Name', sClass: 'center' },
      {
        sTitle: 'Size'
        bSearchable: false
        mRender: (data, operation, row) =>
          if operation == 'display'
            @formatFileSize(data)
          else
            data
        sClass: 'center'
      },
      {
        sTitle: 'Date'
        bSearchable: false
        mRender: (data, operation, row) =>
          if operation == 'display'
            App.Lib.DateTimeHelper.timeToHuman(data)
          else
            data
        sClass: 'center'
      }
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

    @$('.uploaded').dataTable
      aaData: data
      aoColumns: columns
      bLengthChange: false


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


  _confirmDestroyAsset: (e, data) =>
    if @assetType == 'image'
      if confirm("Are you sure you want to delete this image and corresponding sprites from all the scenes?")
        @_destroyAsset(e, data)
    else
      @_destroyAsset(e, data)


  _destroyAsset: (e, data) ->
    $.blueimpUI.fileupload.prototype.options.destroy.call(@fileUpload, e, data)


  _toggleUploadedAssetsHeader: (delta=0)=>
    nr = @fileUpload.data('fileupload').options.filesContainer.children().length + delta
    uploadableAssets = @fileUpload.find('.toUpload thead')
    if nr > 0
      uploadableAssets.show()
    else
      uploadableAssets.hide()


