##
# Show the current assets, allow deleting them, and uploading new ones.
#
class App.Views.AssetLibrary extends Backbone.View
  template: JST['app/templates/assets/library']

  events:
    'click .video-thumbnail' : 'playVideo'


  initialize: ->
    @assetType = @options.assetType
    @assets = @options.assets
    @acceptedFileTypes = @acceptedFileTypes(@assetType)


  render: ->
    @$el.html @template(assetType: @assetType, acceptedFileTypes: @acceptedFileTypes, assets: @assets)
    @initUploader()

    @assetsView = new App.Views.AssetIndex
      collection: @assets
      assetType:  @assetType
      allowDelete: true
      el: @$('.uploaded')
    @assetsView.render()

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

    App.trackUserAction 'Previewed video'


  _toggleUploadedAssetsHeader: (delta=0)=>
    nr = @fileUpload.find('.files tr').length + delta
    uploadableAssets = @fileUpload.find('.toUpload thead')
    if nr > 0
      uploadableAssets.show()
    else
      uploadableAssets.hide()
