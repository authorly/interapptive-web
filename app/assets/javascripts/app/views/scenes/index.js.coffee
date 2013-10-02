class App.Views.SceneIndex extends Backbone.View
  listViewToggleTemplate: JST['app/templates/scenes/list_view_toggle']

  className: 'scene-list'

  tagName:   'ul'

  events:
    'click  span':   'onSceneClick'
    'click .delete': 'deleteScene'


  DELETE_SCENE_MSG: '\nYou are about to delete a scene and all its keyframes.\n\n\nAre you sure you want to continue?\n'


  initialize: ->
    @collection.on 'add'             , @sceneAdded        , @
    @collection.on 'reset'           , @render            , @
    @collection.on 'remove'          , @sceneRemoved      , @
    @collection.on 'change:positions', @_updatePositions  , @
    @collection.on 'synchronization-start synchronization-end', @_enableDeleteButtons, @
    App.vent.on    'window:resize'   , @adjustSize        , @
    App.currentSelection.on 'change:scene', @sceneChanged, @

    $('.scene-view-toggle a').live 'click', (event) => @toggleListView(event)


  render: ->
    @$el.empty()
    @collection.each @renderScene
    @switchScene(@collection.at(0)) if @collection.length > 0

    @renderListViewToggle()

    @initSortable()

    @adjustSize()

    @


  renderListViewToggle: ->
    @$el.parent().prepend(@listViewToggleTemplate())


  sceneAdded: (scene) ->
    mixpanel.track "Add scene"

    @renderScene(scene)
    @switchScene(scene)


  renderScene: (scene) =>
    view = new App.Views.Scene(model: scene)
    index = @collection.indexOf(scene)
    viewElement = view.render().el
    if index == 0
      @$el.prepend viewElement
    else
      @$el.children().eq(index-1).after(viewElement)


  deleteScene: (event) =>
    event.stopPropagation()
    return if @$el.hasClass('disabled')

    if confirm(@DELETE_SCENE_MSG)
      scene = @collection.get $(event.currentTarget).attr('data-id')
      scene.destroy
        success: -> mixpanel.track "Deleted scene"



  onSceneClick: (event) =>
    mixpanel.track "Selected a scene"

    sceneId = $(event.currentTarget).data 'id'
    scene = @collection.get(sceneId)
    @switchScene(scene)


  switchScene: (scene) ->
    App.currentSelection.set scene: scene


  sceneChanged: (__, scene) ->
    $('li', @el)
      .removeClass('active')
      .find("span.scene-frame[data-id=#{scene.get('id')}]")
      .parent().addClass 'active'


  sceneRemoved: (scene, __, options) ->
    if App.currentSelection.get('scene') == scene
      @switchScene(@collection.at(options.index) || @collection.at(options.index - 1))


  initSortable: =>
    @$el.sortable
      containment : '.sidebar'
      items       : 'li[data-is_main_menu!="1"]'
      axis        : 'y'
      opacity     : 0.6
      update      : @_numberScenes


  adjustSize: ->
    $('#scene-list').css height: "#{$(window).height() - 128}px"
    offset = @$el.offset()?.top || 128
    @$el.css height: "#{$(window).height() - offset}px"


  toggleListView: (event) ->
    toggleEl = $(event.currentTarget)
    return if toggleEl.hasClass('disabled')
    toggleEl.addClass('disabled').siblings().removeClass('disabled')

    @$el.toggleClass('list-view')


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


  _updatePositions: =>
    @$('li[data-is_main_menu!="1"]').each (__, element) =>
      element = $(element)

      if (id = element.data('id'))? && (scene = @collection.get(id))?
        element.find('.page-number').text(scene.get('position') + 1)


  _enableDeleteButtons: (__, synchronizing) ->
    if synchronizing
      @$el.addClass(   'disabled').sortable('option', 'disabled', true)
    else
      @$el.removeClass('disabled').sortable('option', 'disabled', false)

