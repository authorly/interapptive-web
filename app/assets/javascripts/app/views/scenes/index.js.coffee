class App.Views.SceneIndex extends Backbone.View
  events:
    'click .scene-list li span': 'setAsActive'

  template: JST["app/templates/scenes/index"]

  tagName: 'ul'

  className: 'scene-list'

  initialize: ->
    # Ensure our collection is rendered upon loading
    @collection.on('reset', @render, this)
    @collection.on('add', @appendScene, this)

  render: ->
    @collection.each(@appendScene)
    this
    
  setAsActive: (e) ->
    $(e.currentTarget).parent().siblings().removeClass("active")
    $(e.currentTarget).parent().removeClass("active")
    $(e.currentTarget).parent().addClass("active")

    # Get out scene ID data attribute (this is the actual DB-ID)
    scene_id = $(e.currentTarget).data("id")

    # Set currentScene global/helper
    App.currentScene(@collection.get(scene_id))
    
    # Prepare and render correlating keyframe list for clicked scene
    @keyframesCollection = new App.Collections.KeyframesCollection([], {scene_id: App.currentScene().get("id")})
    @keyframesCollection.fetch()
    view = new App.Views.KeyframeIndex(collection: @keyframesCollection)
    $('#keyframe-list').html("")
    $('#keyframe-list').html(view.render().el)
    $('nav.toolbar ul li ul li').removeClass('disabled')

  appendScene: (scene) ->
    view = new App.Views.Scene(model: scene)
    $('.scene-list').prepend(view.render().el)

    # Update scene list index numbers on sidebar
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
