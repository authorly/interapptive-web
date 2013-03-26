class App.Views.ToolbarView extends Backbone.View
  events:
    'click .scene'              : 'addScene'
    'click .keyframe'           : 'addKeyframe'
    'click .animation-keyframe' : 'addAnimationKeyframe'
    'click .edit-text'          : 'addText'
    'click .add-image'          : 'addImage'
    'click .add-hotspot'        : 'addHotspot'
    'click .sync-audio'         : 'alignAudio'
    'click .actions'            : 'showActionLibrary'
    'click .scene-options'      : 'showSceneOptions'
    'click .preview'            : 'showPreview'


  initialize: ->
    @_enableOnEvent 'can_add:sceneAnimation', '.animation-keyframe'
    @_enableOnEvent 'can_add:keyframeText' ,  '.edit-text'

    App.vent.on 'activate:scene', (scene) =>
      @$('li').removeClass 'disabled'
      if scene.isMainMenu()
        @$('.edit-text,.touch-zones,.animation-keyframe,.keyframe,.sync-audio,.add-hotspot').addClass 'disabled'


  addScene: ->
    App.vent.trigger 'create:scene'


  addKeyframe: ->
    App.vent.trigger 'create:keyframe'


  addAnimationKeyframe: ->
    App.vent.trigger 'create:keyframe', is_animation: true


  addText: (event) ->
    event.preventDefault()
    return if $(event.currentTarget).hasClass('disabled')

    App.vent.trigger 'create:widget', type: 'TextWidget'


  addImage: ->
    App.vent.trigger 'create:image'


  addHotspot: (event) ->
    event.preventDefault()
    return if $(event.currentTarget).hasClass('disabled')

    App.vent.trigger('initialize:hotspotWidget')


  alignAudio: ->
    view = new App.Views.VoiceoverIndex App.currentSelection.get('keyframe')
    App.modalWithView(view: view).show()

    App.vent.trigger 'align:audio'


  showSceneOptions: ->
    App.vent.trigger('show:sceneform')


  showPreview: -> App.showSimulator()


  showActionLibrary: ->
    @actionDefinitions = new App.Collections.ActionDefinitionsCollection()
    @actionDefinitions.fetch
      success: =>
        activeDefinition = @actionDefinitions.first
        view = new App.Views.ActionFormContainer actionDefinitions: @actionDefinitions
        App.modalWithView(view: view).show()


  _enableOnEvent: (event, selector) ->
    App.vent.on event, (enable) =>
      element = @$(selector)
      if enable
        element.removeClass 'disabled'
      else
        element.addClass 'disabled'
