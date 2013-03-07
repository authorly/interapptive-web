class App.Views.AssetLibrary extends Backbone.View
  template: JST['app/templates/assets/library']

  events:
    'click .video-thumbnail' : 'playVideo'


  initialize: (assetType, assets) ->
    @assetType = assetType
    @assets = assets
    @acceptedFileTypes = @acceptedFileTypes(@assetType)

    @assets.on 'reset', @render, @
    @assets.fetch()


  render: ->
    @$el.html @template(assetType: @assetType, acceptedFileTypes: @acceptedFileTypes, assets: @assets)
    @initAssetLib()
    @loadAndShowFileData()
    @


  initAssetLib: ->
    $('.content-modal').addClass 'asset-library-modal'
    @$('#fileupload').fileupload(
      acceptFileTypes: @fileTypePattern(@assetType)
      downloadTemplate : JST["app/templates/assets/#{@assetType}s/download"]
      uploadTemplate   : JST["app/templates/assets/#{@assetType}s/upload"]
    ).bind('fileuploaddestroyed',  =>
      @assets.fetch()
      # App.vent.trigger('destroyed:font', data) if @assetType is 'font'
    ).bind('fileuploadcompleted', (event, data) =>
      @assets.fetch()
      App.vent.trigger('uploaded:fonts', data.result) if @assetType is 'font'
    )


  loadAndShowFileData: ->
    files = @assets.map (asset) -> asset.attributes

    fileData = @$('#fileupload').data 'fileupload'
    fileData._adjustMaxNumberOfFiles(files.length)

    template = fileData._renderDownload(files).prependTo @$('#fileupload .files')
    fileData._reflow = fileData._transition and template.length and
      template[0].offsetWidth

    template.addClass 'in'

    @$('#loading').remove()
    @$('#searchtable').show()

    @$('.table-striped').advancedtable
      searchCaseSensitive : false
      afterRedrawThis     : @
      afterRedraw         : @attachDeleteEvent
      searchField         : '#search'
      loadElement         : '#loader'
      descImage           : '/assets/advancedtable/down.png'
      ascImage            : '/assets/advancedtable/up.png'


  closeAssetLib: ->
    @$('#fileupload').fileupload 'disable'
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
    $('.content-modal').hide()

    video = $(em.currentTarget).data('video')
    App.lightboxWithView(view: new App.Views.VideoPlayer(video)).show()


  attachDeleteEvent: ->
    $('.delete-asset').click(@hideRow)


  hideRow: (event) ->
    $(event.target).closest('tr').hide()
