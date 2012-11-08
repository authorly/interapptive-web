class App.Views.SceneIndex extends Backbone.View
  template: JST["app/templates/scenes/index"]
  tagName: 'ul'
  className: 'scene-list'
  events:
    'click    span a.delete': 'destroyScene'
    'click .scene-list span': 'clickScene'

  initialize: ->
    @collection.on('reset', @render, this)
    @collection.on('add', @appendScene, this)

  render: ->
    $(@el).html('')

    @collection.each (scene) => @appendScene(scene)

    $('.scene-list li:first span:first').click()

    @initSortable() if @collection?

    $("#scene-list").css height: ($(window).height()) + "px"
    $(".scene-list").css height: ($(window).height()) + "px"

    this

  createScene: =>
    scene = new App.Models.Scene

    scene.save storybook_id: App.currentStorybook().get('id'),
      wait: true
      success: (scene, response) =>
        @collection.add scene
        @setActiveScene scene
        $('.scene-list li:last span:first').click()
        @scrollToTop()
        @numberScenes()
    scene

  appendScene: (scene) ->
    view = new App.Views.Scene(model: scene)

    $(@el).append(view.render().el)


  setActiveScene: (scene) ->
    App.builder.widgetLayer.removeAllChildrenWithCleanup()

    App.currentScene scene

    App.keyframeList().collection.scene_id = scene.get("id")
    App.keyframeList().collection.fetch()

    App.activeActionsCollection.fetch()

    $('#keyframe-list').html("").html(App.keyframeList().el)
    $('nav.toolbar ul li ul li').removeClass 'disabled'

  destroyScene: (event) =>
    message = '\nYou are about to delete a scene and all its keyframes.\n\n\nAre you sure you want to continue?\n'
    target  = $(event.currentTarget)
    sceneId = target.attr('data-id')
    sceneEl = target.parent().parent()
    scene   = App.sceneList().collection.get(sceneId)

    event.stopPropagation()

    if confirm(message)
      scene.destroy
        success: =>
          sceneEl.remove() and $('.scene-list li:first span:first').click()
          @numberScenes()

  clickScene: (event) ->
    target  = $(event.currentTarget)
    sceneId = target.data("id")
    sceneEl = target.parent()

    sceneEl.siblings().removeClass("active")
    sceneEl.removeClass("active")
    sceneEl.addClass("active")

    @setActiveScene @collection.get(sceneId)


  initSortable: =>
    @numberScenes()

    $(@el).sortable
      opacity: 0.6
      containment: '.sidebar'
      axis: 'y'
      update: =>
        @numberScenes()

        $.ajax
          contentType:"application/json"
          dataType: 'json'
          type: 'POST'
          data: JSON.stringify(@scenePositionsJSONArray())
          url: "#{@collection.ordinalUpdateUrl(App.currentScene().get('id'))}"
          complete: =>
            $(@el).sortable('refresh')

  scenePositionsJSONArray: ->
    JSON = {}
    JSON.scenes = []

    # Don't use cached element @el! C.W.
    $('.scene-list li span.scene-frame').each (index, element) ->
      JSON.scenes.push
        id: $(element).data 'id'
        position: index+1

    JSON

  numberScenes: ->
    $('.page-number').each (index, element) ->
      $(element).empty().html(index+1)

  scrollToTop: ->
    el = $('.scene-list')
    el.scrollTop(el.find('li:first').height()*el.find('li').size())
