class App.Views.ToolbarView extends Backbone.View
  events:
    'click .add-scene': 'addScene'
    'click .add-keyframe': 'addKeyframe'

  render: ->
    $el = $(this.el)

  addScene: ->
    @scene = new App.Models.Scene
    @scene.save storybook_id: App.currentStorybook().get('id')

  addKeyframe: ->
    @keyframe = new App.Models.Keyframe
    @keyframe.save scene_id: @scene.get('id')
