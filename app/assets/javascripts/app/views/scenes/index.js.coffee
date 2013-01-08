class App.Views.SceneIndex extends Backbone.View
  template: JST["app/templates/scenes/index"]

  tagName: 'ul'

  className: 'scene-list'

  events:
    'click    span a.delete': 'deleteScene'
    'click .scene-list span': 'onSceneClick'

  initialize: ->
    @collection.on('reset',  @render, @)
    @collection.on('change:positions', @render, @)
    @collection.on('add',    @appendSceneElement, @)
    @collection.on('remove', @removeScene, @)
    App.vent.on('window:resize', @adjustSize, @)


  render: ->
    @$el.empty()
    @collection.each (scene) => @appendSceneElement(scene)
    @toggleSceneChange(@collection.at(0)) if @collection.length > 0

    @initSortable()

    @adjustSize()

    @


  appendSceneElement: (scene) ->
    view = new App.Views.Scene(model: scene)
    @$el.append view.render().el


  deleteScene: (event) =>
    event.stopPropagation()
    # TODO: Prevent this from working in the event there is only one scene?
    message = '\nYou are about to delete a scene and all its keyframes.\n\n\nAre you sure you want to continue?\n'

    if confirm(message)
      target  = $(event.currentTarget)
      scene = @collection.get(target.attr('data-id'))
      scene.destroy
        success: => @collection.remove(scene)


  removeScene: (scene) =>
    $("li[data-id=#{scene.id}]").remove()
    $('.keyframe-list').empty()
    @toggleSceneChange scene


  onSceneClick: (event) =>
    $('.keyframe-list').empty()
    $('.text_widget').remove()
    sceneId = $(event.currentTarget).data 'id'
    scene = @collection.get(sceneId)
    @toggleSceneChange scene


  toggleSceneChange: (newScene) =>
    @switchActiveElement(newScene)

    App.currentSelection.set scene: newScene


  switchActiveElement: (scene) =>
    $('li', @el)
      .removeClass('active')
      .find("span.scene-frame[data-id=#{scene.get('id')}]")
      .parent().addClass('active')


  initSortable: =>
    $(@el).sortable
      opacity: 0.6
      containment: '.sidebar'
      axis: 'y'
      update: @_numberScenes
      items: 'li[data-is_main_menu!="1"]'


  adjustSize: ->
    $("#scene-list, .scene-list").css height: ($(window).height()) + "px"


  _numberScenes: =>
    @$('li[data-is_main_menu!="1"]').each (index, element) =>
      # console.log index, element
      element = $(element)

      if (id = element.data('id'))? && (scene = @collection.get(id))?
        scene.set position: index

    # Backbone bug - without timeout the model is added twice
    window.setTimeout ( =>
      @collection.sort silent: true
      @collection.savePositions()
    ), 0
