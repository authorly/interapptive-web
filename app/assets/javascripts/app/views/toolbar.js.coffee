class App.Views.ToolbarView extends Backbone.View
  events:
    'click .add-scene': 'addScene'
    'click .add-keyframe': 'addKeyframe'
    'click .edit-text': 'editText'
    'click .images': 'showImageLibModal'

  render: ->
    $el = $(this.el)

  addScene: ->
    @scene = App.sceneList().createScene()

  addKeyframe: ->
    App.keyframeList().createKeyframe()

  editText: ->
    $("#text").focus() unless $('.edit-text').hasClass('disabled')

  showImageLibModal: ->
    $("#image-upload-modal").modal "show"
