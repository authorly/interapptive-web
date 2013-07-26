class App.Views.UploadingAsset extends Backbone.View
  tagName:  'li'
  template: JST['app/templates/assets/library/uploading_asset']
  events:
    'click .delete': 'stopUpload'

  render: ->
    @$el.html @template(
      asset: @model
      type: @type()
    )

    @


  type: ->
    extension = @model.get('name').match(/[^.]+$/)[0]
    if ['jpg', 'jpeg', 'gif', 'png'].indexOf(extension) > -1
      'image'
    else if ['mov', 'mpg', 'mpeg', 'mkv', 'm4v', 'avi', 'flv', 'mp4'].indexOf(extension) > -1
      'video'
    else if ['mp3', 'wav', 'aac', 'm4a'].indexOf(extension) > -1
      'sound'


  stopUpload: ->
    @model.get('xhr').abort()
