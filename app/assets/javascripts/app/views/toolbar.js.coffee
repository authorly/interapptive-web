class App.Views.ToolbarView extends Backbone.View
  events:
    'click .add-scene': 'addScene'
    'click .add-keyframe': 'addKeyframe'
    'click .edit-text': 'editText'

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

        # Prepare and render correlating keyframe list for clicked scene
        @keyframesCollection = new App.Collections.KeyframesCollection([], {scene_id: App.currentScene().get("id")})
        @keyframesCollection.fetch()
        view = new App.Views.KeyframeIndex(collection: @keyframesCollection)
        $('#keyframe-list').html(view.render().el)

        # For demo purposes, will likely be removed
        $('nav.toolbar ul li ul li').removeClass('disabled')

        # Update list index numbers
        $(".scene-list li").each (index) ->
          scene_count = $(this).parent().find('span span.number').size() - index
          number_holder =  $(this).find('span span span')
          number_holder.html scene_count
          # Different styles (font-sizes, placement) for different brackets (0-9,10-19,20-29, etc.)
          if scene_count > 9
            number_holder.removeClass "inner-single-digit"
            number_holder.addClass "inner"
          else
            number_holder.removeClass "inner"
            number_holder.addClass "inner-single-digit"

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
