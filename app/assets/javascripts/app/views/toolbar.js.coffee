class App.Views.ToolbarView extends Backbone.View
  events:
    'click .add-scene': 'addScene'
    'click .add-keyframe': 'addKeyframe'

  render: ->
    $el = $(this.el)

  addScene: ->
    @scene = new App.Models.Scene
    @scene.save storybook_id: App.currentStorybook().get('id'),
      wait: true
      success: (scene, response) ->
       # Build and render view
        view = new App.Views.Scene(model: scene)
        $('.scene-list').prepend(view.render().el)
        $(".scene-list li").removeClass "active"
        $(".scene-list li").first().addClass "active"
        
        # Assign current scene
        App.currentScene(scene)
        
        # For demo purposes, will likely be removed
        $('nav.toolbar ul li ul li').removeClass('disabled')

  addKeyframe: ->
    @keyframe = new App.Models.Keyframe
    @keyframe.save scene_id: App.currentScene().get('id'),
      wait: true
      success: (keyframe, response) ->
        view = new App.Views.Keyframe(model: @keyframe)
        $('.keyframe-list').prepend(view.render().el)
        $(".keyframe-list li").removeClass "active"
        $(".keyframe-list li").first().addClass "active"
