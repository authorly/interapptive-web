window.App =

  Models:      {}
  Views:       {}
  Collections: {}
  Routers:     {}
  Lib:         {}
  Config:      {}

  init: ->
    # A global vent object that allows decoupled communication between
    # different parts of the application. For example, the content of the
    # main view and the buttons in the toolbar.
    @vent = _.extend {}, Backbone.Events
    @vent.on 'all', ->
      console.log 'vent', arguments # debug everything going through the vent
      console.trace()

    @vent.on 'reset:palettes', @_resetPalettes, @
    @vent.on 'toggle:palette', @_togglePalette, @

    @vent.on 'initialize:hotspotWidget', @_openHotspotModal, @

    @currentSelection = new Backbone.Model
      storybook: null
      scene: null
      keyframe: null
      text_widget: null
    @currentWidgets = new App.Collections.CurrentWidgets

    @toolbar   = new App.Views.ToolbarView  el: $('#toolbar')
    @file_menu = new App.Views.FileMenuView el: $('#file-menu')

    @spritesListPalette = new App.Views.PaletteContainer
      view       : new App.Views.SpriteListPalette(collection: @currentWidgets)
      el         : $('#sprite-list-palette')
      title      : 'Scene Images'
      alsoResize : '#sprite-list-palette ul li span'

    @textEditorPalette = new App.Views.PaletteContainer
      title: 'Font Settings'
      view : new App.Views.TextEditorPalette
      el   : $('#text-editor-palette')

    @palettes = [ @textEditorPalette, @spritesListPalette ] #, @spriteEditorPalette


    @currentSelection.on 'change:storybook', (__, storybook) =>
      @_openStorybook(storybook)

    @currentSelection.on 'change:scene', (__, scene) =>
      App.vent.trigger 'activate:scene', scene

      @keyframesView.remove() if @keyframesView?
      @keyframesView = new App.Views.KeyframeIndex(collection: scene.keyframes)
      $('#keyframe-list').html @keyframesView.render().el
      scene.fetchKeyframes()


    @vent.on 'hide:modal', @hideModal, @

    @vent.on 'create:scene', ->
      App.currentSelection.get('storybook').addNewScene()

    @vent.on 'create:keyframe', (attributes) ->
      App.currentSelection.get('scene').addNewKeyframe(attributes)

    @vent.on 'create:widget', (attributes) ->
      container = App.Collections.Widgets.containers[attributes.type]
      App.currentSelection.get(container).widgets.add(attributes)

    @vent.on 'create:image', ->
      scene = App.currentSelection.get('scene')
      view = new App.Views.SpriteIndex(collection: scene.storybook.images)

      imageSelected = (image) ->
        scene.widgets.add
          type: 'SpriteWidget'
          url:      image.get 'url'
          filename: image.get 'name'
        scene.save()

        view.off('select', imageSelected)
        App.modalWithView().hide()

      view.on 'select', imageSelected
      App.modalWithView(view: view).show()


    @vent.on 'show:sceneform', ->
      view = new App.Views.SceneForm(model: App.currentSelection.get('scene'))
      App.modalWithView(view: view).show()

    @vent.on 'change:keyframeWidgets', (keyframe) =>
      return unless App.currentSelection.get('keyframe') == keyframe
      @saveCanvasAsPreview(keyframe)

    @vent.on 'change:sceneWidgets load:sprite', =>
      keyframe = App.currentSelection.get('keyframe')
      @saveCanvasAsPreview(keyframe)


  saveCanvasAsPreview: (keyframe) ->
    window.setTimeout ( ->
      App.Builder.Widgets.WidgetLayer.updateKeyframePreview(keyframe)
    ), 200 # wait for the changes to be shown in the canvas


    # @fontsCollection =         new App.Collections.FontsCollection         []
    # @soundsCollection =        new App.Collections.SoundsCollection        []
    # @keyframesTextCollection = new App.Collections.KeyframeTextsCollection []
    # @activeActionsCollection = new App.Collections.ActionsCollection       []

    # @keyframeTextList  new App.Views.KeyframeTextIndex collection: @keyframesTextCollection, el: $('#canvas-wrapper')

    # @contentModal =   new App.Views.Modal className: 'content-modal'

    # @spriteEditorPalette = new App.Views.PaletteContainer
      # view      : new App.Views.SpriteEditorPalette
      # el        : $('#sprite-editor-palette')
      # resizable : false



  _togglePalette: (palette) ->
    # translate from generic event names to variable names in this file
    # (to avoid coupling the names)
    palette = switch palette
      when 'sceneImages' then @spritesListPalette
      when 'fontEditor'  then @textEditorPalette
      # when 'imageEditor':
    palette.$el.toggle() if palette?


  _openStorybook: (storybook) ->
    scenesIndex = new App.Views.SceneIndex(collection: storybook.scenes)
    $('#scene-list').html(scenesIndex.render().el)

    storybook.fetchCollections()


  _openHotspotModal: (widget) ->
    view = new App.Views.HotspotsIndex(widget: widget, storybook: @currentSelection.get('storybook'))
    @modalWithView(view: view).show()


  _resetPalettes: ->
    palette.reset() for palette in @palettes


  # #
  # #  Temporarily Out of Service.
  # #
  # #    @activeActionsWindow(new App.Views.ActiveActionsList collection: @activeActionsCollection)
  # #
  # #    activeActionsWindow: (view) ->
  # #      if view
  # #        @actionsWindow = new App.Views.WidgetWindow(
  # #          view:       view,
  # #          el:         $('#active-actions-window'),
  # #          alsoResize: '#active-actions'
  # #        )
  # #      else
  # #        @actionsWindow
  # #

  initModals: ->
    $('.content-modal').modal(backdrop: true).modal('hide')
    $('.lightbox-modal').modal().modal('hide').on 'hide', App.pauseVideos

    # RFCTR: Should use generic modal view
    $('#storybooks-modal').modal
      backdrop : 'static'
      show     : true
      keyboard : false


  modalWithView: (view) ->
    if view?
      @view = new App.Views.Modal view, className: 'content-modal'

    @view



  hideModal: ->
    @modalWithView().hide()


  # showSimulator: ->
    # @simulator = new App.Views.Simulator(json: App.storybookJSON.toString())

    # @openLargeModal(@simulator)


  # # RFCTR: Use generic modal & add sizing options to it
  # openLargeModal: (view, className='') ->
    # return unless view
    # @closeLargeModal(false)

    # @_modal = new App.Views.LargeModal(view: view, className: 'large-modal')
    # $('body').append(@_modal.render().el)
    # $('.large-modal').modal(backdrop: true)


  # # RFCTR: cont. from above
  # closeLargeModal: (animate=true) ->
   # if @_modal then @_modal.hide()


  # lightboxWithView: (view) ->
    # return @lightboxView unless view?

    # @lightboxView = new App.Views.Lightbox view, className: 'lightbox-modal'


  # currentStorybook: (storybook) ->
    # if storybook
      # # FIXME Need to remove events from old object
      # @storybookJSON = new App.StorybookJSON

      # @scenesCollection.on 'reset', (scenes) =>
        # @storybookJSON.resetPages()
        # scenes.each (scene) => @storybookJSON.createPage(scene)

      # @scenesCollection.on 'add', (scene) =>
        # @storybookJSON.createPage(scene)

      # @scenesCollection.on 'remove', (scene) =>
        # @storybookJSON.destroyPage(scene)

      # @keyframesCollection.on 'reset', (keyframes) =>
        # scene = @currentScene()
        # if keyframes? && keyframes.length > 0 then scene.setPreviewFrom keyframes.at(0)
        # @storybookJSON.resetParagraphs(scene)
        # keyframes.each (keyframe) => @storybookJSON.createParagraph scene, keyframe

      # @keyframesCollection.on 'add', (keyframe) =>
        # @storybookJSON.createParagraph @currentScene(), keyframe

      # @keyframesCollection.on 'remove', (keyframe) =>
        # @storybookJSON.removeParagraph @currentScene(), keyframe

      # @storybook = storybook

    # @storybook


  # currentScene: (scene) ->
    # if scene
      # @scene = scene

      # if $('#keyframe-list ul').length == 0
          # $('#keyframe-list').html App.keyframeList().el

      # App.keyframeList().collection.scene_id = scene.get 'id'
      # App.keyframeList().collection.fetch()

    # @scene


  # currentKeyframe: (keyframe) ->
    # if keyframe
      # @keyframe = keyframe
      # App.vent.trigger 'can_add:keyframeText', keyframe.canAddText()
    # else
      # @keyframe


  # currentKeyframeText: (keyframeText) ->
    # if keyframeText then @keyframeText = keyframeText else @keyframeText


  # sceneList: (list) ->
    # if list then @sceneListView = list else @sceneListView


  # keyframeList: (list) ->
    # if list then @keyframeListView = list else @keyframeListView


  # keyframeTextList: (list) ->
    # if list then @keyframeTextListView = list else @keyframeTextListView


  # selectedText: (textWidget) ->
    # if textWidget then @textWidget = textWidget else @textWidget


  # # RFCTR: Move to asset library view, use vent where needed
  # pauseVideos: ->
    # $('.video-player')[0].pause()
    # $('.content-modal').show()


$ ->
  App.version =
    environment: $('#rails-environment').data('rails-environment'),
    git_head:    $('#rails-environment').data('git-head')

  App.init()
  window.initBuilder()

  $(window).resize -> App.vent.trigger('window:resize')
  App.initModals()

  @storybooksRouter = new App.Routers.StorybooksRouter
  Backbone.history.start()
