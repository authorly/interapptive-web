class App.Services.SwitchSceneService

  constructor: (@oldScene, @newScene) ->
    @sceneList = App.sceneList()

  execute: =>
    @sceneList.switchActiveElement @newScene

    App.builder.widgetLayer.clearWidgets()
    App.builder.widgetLayer.removeAllChildrenWithCleanup()

    App.currentScene @newScene
    App.keyframeList().collection.scene_id = @newScene.get('id')
    App.keyframeList().collection.fetch()

    # App.activeActionsCollection.fetch()
    $('#keyframe-list').html("").html(App.keyframeList().el)
    $('nav.toolbar ul li ul li').removeClass 'disabled'

    App.vent.trigger 'scene:active', @newScene
    
    App.activeSpritesList.removeAll()
    

  showStats: =>
    console.group "Switching scene"
    console.log "OS", @oldScene
    console.log "NS", @newScene
    console.groupEnd()
