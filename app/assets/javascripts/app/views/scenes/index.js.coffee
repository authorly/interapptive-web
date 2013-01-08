class App.Views.SceneIndex extends Backbone.View
  template:  JST['app/templates/scenes/index']

  className: 'scene-list'

  tagName:   'ul'

  events:
    'click  span'   : 'onSceneClick'
    'click .delete' : 'deleteScene'


  @DELETE_SCENE_MSG: '\nYou are about to delete a scene and all its keyframes.\n\n\nAre you sure you want to continue?\n'


  initialize: ->
    @collection.on 'add'             , @appendSceneElement, @
    @collection.on 'reset'           , @render            , @
    @collection.on 'remove'          , @removeScene       , @
    @collection.on 'change:positions', @render            , @
    App.vent.on    'window:resize'   , @adjustSize        , @


  render: ->
    @$el.empty()
    @collection.each (scene) => @appendSceneElement(scene)
    @changeSceneTo @collection.at(0)

    @initSortable()

    @adjustSize()

    @


  appendSceneElement: (scene) ->
    view = new App.Views.Scene(model: scene)
    @$el.append view.render().el


  deleteScene: (event) =>
    event.stopPropagation()

    if confirm @DELETE_SCENE_MSG
      scene = @collection.get($(event.currentTarget).attr 'data-id')
      scene.destroy success: => @collection.remove(scene)


  removeScene: (scene) =>
    App.vent.trigger 'scene:remove'

    @$("li[data-id=#{scene.id}]").remove()


  onSceneClick: (event) =>
    scene = @collection.get $(event.currentTarget).data('id')
    @changeSceneTo scene


  changeSceneTo: (scene) =>
    return if scene is App.currentScene()

    @switchActiveElement(newScene)

    App.currentScene(newScene)

    App.vent.trigger 'scene:active', newScene


  switchActiveElement: (scene) =>
    $('li', @el).
    removeClass('active').
    find("span.scene-frame[data-id=#{scene.get('id')}]").
    parent().addClass 'active'


  initSortable: =>
    @$el.sortable
      containment : '.sidebar'
      items       : 'li[data-is_main_menu!="1"]'
      axis        : 'y'
      opacity     : 0.6
      update      : @_numberScenes


  adjustSize: ->
    $('#scene-list, .scene-list').css height: "#{$(window).height()}px"


  _numberScenes: =>
    @$('li[data-is_main_menu!="1"]').each (index, element) =>
      element = $(element)

      if (id = element.data('id'))? && (scene = @collection.get(id))?
        scene.set position: index

    # Backbone bug - without timeout the model is added twice
    window.setTimeout ( =>
      @collection.sort silent: true
      @collection.savePositions()
    ), 0