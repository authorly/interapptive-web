class App.Views.SceneIndex extends Backbone.View
  template: JST["app/templates/scenes/index"]
  tagName: 'ul'
  className: 'scene-list'
  events:
    'click    span a.delete': 'destroyScene'
    'click .scene-list span': 'onSceneClick'

  initialize: ->
    @collection.on('reset', @render, this)
    @collection.on('add', @appendSceneElement, this)

  render: ->
    $(@el).html('')

    @collection.each (scene) => @appendSceneElement(scene)

    $('.scene-list li:first span:first').click()

    @initSortable() if @collection?

    $("#scene-list").css height: ($(window).height()) + "px"
    $(".scene-list").css height: ($(window).height()) + "px"

    this


  createScene: =>
    scene = new App.Models.Scene

    scene.save(storybook_id: App.currentStorybook().get('id'),
      wait: true
      success: (scene, response) =>
        @collection.add scene 

        service = new App.Services.SwitchSceneService(App.currentScene(), scene)
        service.execute()

        @scrollToTop()
        @renumberScenes()
    )

    scene

  appendSceneElement: (scene) ->
    view = new App.Views.Scene(model: scene)
    $(@el).append(view.render().el)

  destroyScene: (event) =>
    # TODO: Prevent this from working in the event there is only one scene?
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
          @renumberScenes()

  onSceneClick: (event) =>
    sceneId = $(event.currentTarget).data 'id'
    scene = @collection.get sceneId
    @toggleSceneChange scene

  toggleSceneChange: (scene) =>
    return if scene is App.currentScene()
    service = new App.Services.SwitchSceneService(App.currentScene(), scene)
    service.execute()

  switchActiveElement: (scene) =>
    $('li', @el)
      .removeClass('active')
      .find("span.scene-frame[data-id=#{scene.get('id')}]")
      .parent().addClass('active')

  initSortable: =>
    @renumberScenes()

    $(@el).sortable
      opacity: 0.6
      containment: '.sidebar'
      axis: 'y'
      update: =>
        @renumberScenes()

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

  renumberScenes: ->
    $('.page-number').each (index, element) ->
      $(element).empty().html(index+1)

  scrollToTop: ->
    el = $('.scene-list')
    el.scrollTop(el.find('li:first').height() * el.find('li').size())
