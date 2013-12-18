class App.Views.AssetUploader extends Backbone.View
  ACCEPTED_FILE_TYPES = ['jpg', 'jpeg', 'gif', 'png', 'mov', 'mpg', 'mpeg', 'mkv', 'm4v', 'avi', 'flv', 'mp4', 'mp3', 'wav', 'aac', 'm4a']

  initialize: ->
    @assetIdCounter = new App.Lib.Counter
    @nrFailedUploads = 0


  setStorybook: (storybook) ->
    @$el.fileupload 'option', 'url', storybook.baseUrl() + '/assets.json'


  render: ->
    @$el
      .attr('accept', (_.map @acceptedExtensions(), (type) -> ".#{type}").join(','))
      .fileupload(
        dataType: 'json'
        acceptFileTypes: @fileTypePattern(ACCEPTED_FILE_TYPES)
        limitConcurrentUploads: 15
        add: @_fileAdded
      ).bind('fileuploaddone', @_uploadCompleted
      ).bind('fileuploadfail', @_uploadFailed
      ).bind('fileuploadstop', @_uploadStopped
      )


  showUploadUI: ->
    @$el.click()


  _fileAdded: (e, data) =>
    App.trackUserAction 'Uploaded file', type: data.files[0].type
    data.context = $('<span/>')
    @$el.append data.context
    xhr = data.submit()

    data.context.data 'data', xhr: xhr, id: @assetIdCounter.next()
    @trigger 'add', data


  _uploadCompleted: (e, data) =>
    @trigger 'done', data


  _uploadFailed: (e, data) =>
    @nrFailedUploads += 1

    if data.files[0].error?
      alert "Cannot add #{data.files[0].name}"
    @trigger 'fail', data


  _uploadStopped: =>
    if @nrFailedUploads > 0
      @trigger 'fail:global', @nrFailedUploads
      @nrFailedUploads = 0


  getData: (response) ->
    response.context.data('data')


  fileTypePattern: (types) ->
    new RegExp("\.(#{types.join('|')})$", 'i')


  acceptedExtensions: ->
    _.union(ACCEPTED_FILE_TYPES, _.map(ACCEPTED_FILE_TYPES, (type) -> type.toUpperCase()))
