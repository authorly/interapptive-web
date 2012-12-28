DELETE_SCENE_MSG = '\nYou are about to delete a scene and all its keyframes.\n\n\nAre you sure you want to continue?\n'

class App.Views.SceneIndex extends Backbone.View
  template:  JST['app/templates/scenes/index']

  tagName:   'ul'

  className: 'scene-list'

  events:
    'click span'    : 'onSceneClick'
    'click .delete' : 'deleteScene'


  initialize: ->
    @collection.on 'add             ' , @appendSceneElement , @
    @collection.on 'reset           ' , @render             , @
    @collection.on 'remove          ' , @removeScene        , @
    @collection.on 'change:positions' , @render             , @
    App.vent.on    'window:resize   ' , @adjustSize         , @


  render: ->
    @$el.empty()

    @collection.each (scene) => @appendSceneElement(scene)

    # Use memoized here, see notes
    $('.scene-list li:first span:first').cli  ck()

    @initSortable() if @collection?
    @adjustSize()

    @


  appendSceneElement: (scene) ->
    view = new App.Views.Scene(model: scene)
    @$el.append view.render().el


  deleteScene: (event) =>
    event.stopPropagation()

    if confirm(DELETE_SCENE_MSG)
      id  =   $(event.currentTarget).attr('data-id')
      scene = @collection.get(id)
      scene.destroy
        success: => @collection.remove(scene)


  removeScene: (scene) =>
    $("li[data-id=#{scene.id}]").remove()

    # This method (removeScene)
    #  Should breathe into vent; keyframe index should react
    #   and empty itself accordingly
    $('.keyframe-list').empty()

    # This toggle should be triggered by vent, not called
    @toggleSceneChange scene


  onSceneClick: (event) =>
    # Should blow into vent
    # Be sure to dispose of below views properly during refactor
    $('.keyframe-list').empty()
    $('.text_widget').remove()

    sceneId = $(event.currentTarget).data('id')
    scene =   @collection.get(sceneId)

    # Should be done through vent
    @toggleSceneChange(scene)


  toggleSceneChange: (scene) =>
    return if scene is App.currentScene()
    service = new App.Services.SwitchSceneService(App.currentScene(), scene)
    service.execute()


  switchActiveElement: (scene) =>
    $('li', @el).
      removeClass('active').
      find("span.scene-frame[data-id=#{scene.get('id')}]").
      parent().addClass('active')


  initSortable: =>
    @$el.sortable
      axis        : 'y'
      containment : '.sidebar'
      items       : 'li[data-is_main_menu!="1"]'
      opacity     : 0.6
      update      : @_numberScenes


  adjustSize: ->
    $('#scene-list, .scene-list').css  height: "#{$(window).height()}px"


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
