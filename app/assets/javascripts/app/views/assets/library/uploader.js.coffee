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
      ).bind('fileuploadadd', (e, data) ->
        data.submit()
      ).bind('fileuploaddone', (e, data) ->
        console.log 'done', data
      ).bind('fileuploadfail', (e, data) ->
        failed = _.filter data.files, (file) -> file.error?
        alert "Cannot add media because these files can not be uploaded: #{_.pluck(failed, 'name').join(', ')}."
      )


  fileTypePattern: (types) ->
    new RegExp("\.(#{types.join('|')})$", 'i')
