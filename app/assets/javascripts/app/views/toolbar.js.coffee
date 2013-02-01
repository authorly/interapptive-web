class App.Views.ToolbarView extends Backbone.View
  events:
    'click .scene'              : 'addScene'
    'click .keyframe'           : 'addKeyframe'
    'click .animation-keyframe' : 'addAnimationKeyframe'
    'click .edit-text'          : 'addText'
    'click .add-image'          : 'addImage'
    'click .add-hotspot'        : 'addHotspot'
    'click .sync-audio'         : 'alignAudio'
    'click .images'             : 'showImageLibrary'
    'click .videos'             : 'showVideoLibrary'
    'click .fonts'              : 'showFontLibrary'
    'click .sounds'             : 'showSoundLibrary'
    'click .actions'            : 'showActionLibrary'
    'click .scene-options'      : 'showSceneOptions'
    'click .preview'            : 'showPreview'


  initialize: ->
    @_enableOnEvent 'scene:can_add_animation', '.animation-keyframe'
    @_enableOnEvent 'keyframe:can_add_text'  , '.edit-text'

    App.vent.on 'scene:active', (scene) =>
      @$('li').removeClass 'disabled'
      if scene.isMainMenu()
        @$('.edit-text,.touch-zones,.animation-keyframe,.keyframe').addClass 'disabled'


  addScene: ->
    App.vent.trigger 'create:scene'


  addKeyframe: ->
    App.vent.trigger 'create:keyframe'


  addAnimationKeyframe: ->
    App.vent.trigger 'create:keyframe', is_animation: true


  addText: ->
    # TODO RFCTR create a App.Models.TextWidget and just add it to the
    # current keyframe's collection of widgets
    widget = new App.Builder.Widgets.TextWidget
      string:   'Enter some text...'
      keyframe: App.currentSelection.get('keyframe')
    widget.create()


  addImage: ->
    App.vent.trigger 'create:image'


  addHotspot: (event) ->
    return if $(event.currentTarget).hasClass('disabled')

    App.vent.trigger 'create:widget', type: 'HotspotWidget'


  # addSprite: ->
    # imageSelected = (image) =>
      # widget = new App.Builder.Widgets.SpriteWidget
        # url:      image.get 'url'
        # filename: image.get 'name'
        # scene:    App.currentSelection.get 'scene'
        # zOrder:   $('#active-sprites-window ul li').size() || 1
      # widget.save()
      # App.builder.widgetLayer.addWidget(widget)
      # App.modalWithView().hide()
      # view.off('select', imageSelected)

    # view = new App.Views.SpriteIndex(collection: new App.Collections.ImagesCollection [])
    # view.on('select', imageSelected)
    # App.modalWithView(view: view).show()


  alignAudio: ->
    view = new App.Views.AudioIndex App.currentSelection.get('keyframe')
    App.modalWithView(view: view).show()

    App.vent.trigger 'audio:align'


  showSceneOptions: ->
    App.vent.trigger('show:sceneform')


  showImageLibrary: -> @loadDataFor 'image'


  showVideoLibrary: -> @loadDataFor 'video'


  showFontLibrary:  -> @loadDataFor 'font'


  showSoundLibrary: -> @loadDataFor 'sound'


  showPreview: -> App.showSimulator()


  showActionLibrary: ->
    @actionDefinitions = new App.Collections.ActionDefinitionsCollection()
    @actionDefinitions.fetch
      success: =>
        activeDefinition = @actionDefinitions.first
        view = new App.Views.ActionFormContainer actionDefinitions: @actionDefinitions
        App.modalWithView(view: view).show()


  loadDataFor: (assetType) ->
    storybook = App.currentSelection.get('storybook')
    view = new App.Views.AssetLibrary assetType, storybook[assetType + 's']

    App.modalWithView(view: view).show()


  # _addWidget: (widget) ->
    # keyframe = App.currentKeyframe()
    # App.builder.widgetLayer.addWidget widget
    # keyframe.addWidget widget

    # widget.on 'change', -> keyframe.updateWidget widget


  _enableOnEvent: (event, selector) ->
    App.vent.on event, (enable) =>
      element = @$(selector)
      if enable
        element.removeClass 'disabled'
      else
        element.addClass 'disabled'
