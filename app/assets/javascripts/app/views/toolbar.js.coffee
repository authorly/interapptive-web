class App.Views.ToolbarView extends Backbone.View
  events:
    'click .add-scene': 'addScene'

  render: ->
    $el = $(this.el)

  addScene: ->
    @scene = new App.Models.Scene
    @scene.save storybook_id: App.currentStorybook().get('id')
