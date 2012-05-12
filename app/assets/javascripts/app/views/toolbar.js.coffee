class App.Views.ToolbarView extends Backbone.View
  events:
    'click .add-scene': 'addScene'
    'click .add-keyframe': 'addKeyframe'
    'click .edit-text': 'editText'

  render: ->
    $el = $(this.el)

  addScene: ->
    @scene = App.sceneList().createScene()

  addKeyframe: ->
    @keyframe = new App.Models.Keyframe
    @keyframe.save scene_id: App.currentScene().get('id'),
      wait: true
      success: (keyframe, response) ->
        view = new App.Views.Keyframe(model: @keyframe)
        $('.keyframe-list').prepend(view.render().el)
        $(".keyframe-list li").removeClass "active"
        $(".keyframe-list li").last().addClass "active"

  editText: ->
    $("#text").focus() unless $('.edit-text').hasClass('disabled')
