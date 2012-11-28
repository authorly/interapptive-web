class App.Views.SceneIndex extends Backbone.View
  template: JST["app/templates/scenes/index"]

  tagName: 'ul'

  className: 'scene-list'

  events:
    'click  span a.delete':   'deleteScene'
    'click .scene-list span': 'selectScene'


  initialize: ->
    @collection.on('reset',  @render, @)
    @collection.on('change:positions', @render, @)
    @collection.on('add',    @appendScene, @)
    @collection.on('remove', @removeScene, @)
    App.vent.on('window:resize', @adjustSize, @)


  render: ->
    $(@el).html('')

    if @collection.length > 0
      @collection.each (scene) => @renderScene(scene)
      @setActiveScene()

    @adjustSize()
    @initSortable() if @collection?

    @


  appendScene: (scene) ->
    @renderScene(scene)
    @setActiveScene scene


  renderScene: (scene, index) =>
    view = new App.Views.Scene(model: scene)
    viewElement = view.render().el
    if index == 0
      @$el.prepend viewElement
    else
      @$el.append  viewElement


  setActiveScene: (scene) ->
    scene = @collection.at(@collection.length - 1) unless scene?

    App.builder.widgetLayer.removeAllChildrenWithCleanup()
    App.currentScene scene

    @$('li').removeClass('active').filter("[data-id=#{scene.id}]").addClass('active')

    App.vent.trigger 'scene:active', scene

    #App.activeActionsCollection.fetch()


  deleteScene: (event) =>
    event.stopPropagation()
    message = '\nYou are about to delete a scene and all its keyframes.\n\n\nAre you sure you want to continue?\n'

    if confirm(message)
      target = $(event.currentTarget)
      scene = @collection.get(target.attr('data-id'))
      scene.destroy
        success: => @collection.remove(scene)


  removeScene: (scene) =>
    $("li[data-id=#{scene.id}]").remove()
    @setActiveScene()


  selectScene: (event) ->
    target  = $(event.currentTarget)
    sceneId = target.data("id")
    @setActiveScene @collection.get(sceneId)


  initSortable: =>
    $(@el).sortable
      opacity: 0.6
      containment: '.sidebar'
      axis: 'y'
      update: @_numberScenes
      items: 'li[data-is_main_menu!="1"]'


  adjustSize: ->
    $("#scene-list").css height: ($(window).height()) + "px"
    $(".scene-list").css height: ($(window).height()) + "px"


  _numberScenes: =>
    console.log 'number'
    @$('li[data-is_main_menu!="1"]').each (index, element) =>
      console.log index, element
      element = $(element)

      if (id = element.data('id'))? && (scene = @collection.get(id))?
        scene.set position: index

    # Backbone bug - without timeout the model is added twice
    window.setTimeout ( =>
      @collection.sort silent: true
      @collection.savePositions()
    ), 0
