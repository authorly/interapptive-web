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
    @assets.off 'reset add remove', @loadAndShowFileData, @


  render: ->
    @$el.html @template(assetType: @assetType, acceptedFileTypes: @acceptedFileTypes, assets: @assets)
    @initAssetLib()
    @loadAndShowFileData()
    @


  # TODO invoke this when modal is hidden
  # close: ->
    # @$('#fileupload').fileupload 'disable'
    # $('.content-modal').removeClass 'asset-library-modal'
    # @_removeListeners()



  initAssetLib: ->
    $('.content-modal').addClass 'asset-library-modal'
    @fileUpload = @$('#fileupload').fileupload(
      acceptFileTypes: @fileTypePattern(@assetType)
      singleFileUploads: false
      downloadTemplate : JST["app/templates/assets/#{@assetType}s/download"]
      uploadTemplate   : JST["app/templates/assets/#{@assetType}s/upload"]
      destroy: @_confirmDestroyAsset
    ).bind('fileuploaddestroyed',  (event, data) =>
      deleteButton = $(data.context.context)
      id = deleteButton.closest('tr').find('.preview').data('id')
      @assets.remove @assets.get(id), from_upload: true
    ).bind('fileuploadcompleted', (event, data) =>
      @assets.add data.result, from_upload: true
    )


  loadAndShowFileData: ->
    return if arguments[2]?.from_upload

    files = @assets.map (asset) -> asset.attributes

    fileData = @fileUpload.data 'fileupload'
    fileData._adjustMaxNumberOfFiles(files.length)

    template = fileData._renderDownload(files)
    template.addClass 'in'
    @$('#fileupload .files').html('').append(template)
    fileData._reflow = fileData?._transition and template.length and template[0].offsetWidth

    @$('#loading').remove()

    # 2013-04-30 @dira
    # Advanced table removes all information from the tr - classes, data
    # which interferes with the expectations of the jqueryupload plugin.
    # Before re-enabling this make sure the following scenario works:
    # * upload 2 assets; delete one of them;
    # * refresh the page; delete the remaining asset
    #
    # At all times the collection should have the correct number of elements
    # and there is no JS error.
    #
    # @$('#searchtable').show()
    # @$('.table-striped').advancedtable
      # searchCaseSensitive : false
      # afterRedrawThis     : @
      # afterRedraw         : @attachDeleteEvent
      # searchField         : '#search'
      # loadElement         : '#loader'
      # descImage           : '/assets/advancedtable/down.png'
      # ascImage            : '/assets/advancedtable/up.png'

  closeAssetLib: ->
    @fileUpload.fileupload 'disable'
    $('.content-modal').removeClass 'asset-library-modal'
    @assets.off 'reset', @render, @


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
