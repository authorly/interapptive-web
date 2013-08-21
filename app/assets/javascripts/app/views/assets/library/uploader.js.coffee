class App.Views.AssetUploader extends Backbone.View
  ACCEPTED_FILE_TYPES = ['jpg', 'jpeg', 'gif', 'png', 'mov', 'mpg', 'mpeg', 'mkv', 'm4v', 'avi', 'flv', 'mp4', 'mp3', 'wav', 'aac', 'm4a']

  initialize: ->
    @assetIdCounter = new App.Lib.Counter

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
      )


  showUploadUI: ->
    @$el.click()


  _fileAdded: (e, data) =>
    data.context = $('<span/>')
    @$el.append data.context
    xhr = data.submit()

    data.context.data 'data', xhr: xhr, id: @assetIdCounter.next()
    @trigger 'add', data


  _uploadCompleted: (e, data) =>
    @trigger 'done', data


  _uploadFailed: (e, data) =>
    if data.files[0].error?
      alert "Cannot add #{data.files[0].name}"
    @trigger 'fail', data


  getData: (response) ->
    response.context.data('data')


  fileTypePattern: (types) ->
    new RegExp("\.(#{types.join('|')})$", 'i')


  acceptedExtensions: ->
    _.union(ACCEPTED_FILE_TYPES, _.map(ACCEPTED_FILE_TYPES, (type) -> type.toUpperCase()))
