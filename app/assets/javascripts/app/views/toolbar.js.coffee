class App.Views.ToolbarView extends Backbone.View
  events:
    'click .scene'              : 'addScene'
    'click .keyframe'           : 'addKeyframe'
    'click .animation-keyframe' : 'addAnimationKeyframe'
    'click .edit-text'          : 'addText'
    'click .add-hotspot'        : 'addHotspot'
    'click .sync-audio'         : 'alignAudio'
    # 'click .actions'            : 'showActionLibrary'
    'click .scene-options'      : 'showSceneOptions'
    'click .preview'            : 'showPreview'


  initialize: ->
    @_enableOnEvent 'can_add:keyframe', '.keyframe'
    @_enableOnEvent 'can_add:animationKeyframe', '.animation-keyframe'
    @_enableOnEvent 'can_add:text', '.edit-text'
    @_enableOnEvent 'can_add:voiceover', '.sync-audio'
    @_enableOnEvent 'can_add:scene', '.scene'

    App.vent.on 'activate:scene', (scene) =>
      @$('li').removeClass 'disabled'
      if scene.isMainMenu()
        @$('.edit-text,.touch-zones,.sync-audio,.add-hotspot').addClass 'disabled'


  addScene: ->
    event.preventDefault()
    return if $(event.target).hasClass('disabled')

    App.vent.trigger 'create:scene'


  addKeyframe: ->
    event.preventDefault()
    return if $(event.target).hasClass('disabled')

    App.vent.trigger 'create:keyframe'


  addAnimationKeyframe: ->
    event.preventDefault()
    return if $(event.target).hasClass('disabled')

    App.vent.trigger 'create:keyframe', is_animation: true


  addText: (event) ->
    event.preventDefault()
    return if $(event.target).hasClass('disabled')

    App.vent.trigger 'create:widget', type: 'TextWidget'


  addHotspot: (event) ->
    event.preventDefault()
    return if $(event.target).hasClass('disabled')

    App.vent.trigger('initialize:hotspotWidget')


  alignAudio: (event) ->
    event.preventDefault()
    return if $(event.target).hasClass('disabled')

    view = new App.Views.VoiceoverIndex App.currentSelection.get('keyframe')
    App.modalWithView(view: view).show().modal.on('hide', view.stopVoiceover)


  showSceneOptions: ->
    App.vent.trigger('show:sceneform')


  showPreview: -> App.vent.trigger 'show:simulator'


  # showActionLibrary: ->
    # @actionDefinitions = new App.Collections.ActionDefinitionsCollection()
    # @actionDefinitions.fetch
      # success: =>
        # activeDefinition = @actionDefinitions.first
        # view = new App.Views.ActionFormContainer actionDefinitions: @actionDefinitions
        # App.modalWithView(view: view).show()


  _enableOnEvent: (event, selector) ->
    App.vent.on event, (enable) =>
      element = @$(selector)
      if enable
        element.removeClass 'disabled'
      else
        element.addClass 'disabled'
