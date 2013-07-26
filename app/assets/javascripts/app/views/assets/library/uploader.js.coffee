class App.Views.AssetUploader extends Backbone.View
  ACCEPTED_FILE_TYPES = ['jpg', 'jpeg', 'gif', 'png', 'mov', 'mpg', 'mpeg', 'mkv', 'm4v', 'avi', 'flv', 'mp4', 'mp3', 'wav', 'aac', 'm4a']

  setStorybook: (storybook) ->
    @$el.fileupload 'option', 'url', storybook.baseUrl() + '/assets.json'


  render: ->
    @$el
      .attr('accept', (_.map ACCEPTED_FILE_TYPES, (type) -> ".#{type}").join(','))
      .fileupload(
        dataType: 'json'
        acceptFileTypes: @fileTypePattern(ACCEPTED_FILE_TYPES)
        singleFileUploads: false
        autoUpload: true
      ).bind('fileuploadadd',  (e, data) =>
        @trigger 'add', data.files
      ).bind('fileuploaddone', (e, data) =>
        @trigger 'done', data.files, data.result
      ).bind('fileuploadfail', (e, data) =>
        @trigger 'fail', data.files
        failed = _.filter data.files, (file) -> file.error?
        alert "Cannot add media because these files can not be uploaded: #{_.pluck(failed, 'name').join(', ')}."
      )


  showUploadUI: ->
    @$el.click()


  fileTypePattern: (types) ->
    new RegExp("\.(#{types.join('|')})$", 'i')
