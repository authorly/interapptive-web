class App.Views.ToolbarView extends Backbone.View
  events:
    'click .add-scene'   : 'addScene'
    'click .add-keyframe': 'addKeyframe'
    'click .edit-text'   : 'editText'
    'click .images'      : 'showImageLibrary'
    'click .videos'      : 'showVideoLibrary'
    'click .fonts'       : 'showFontLibrary'
    'click .sounds'      : 'showSoundLibrary'
    'click .actions'     : 'showActionLibrary'

  initialize: ->
    @assetLibraryView = new App.Views.AssetLibrary()

  render: ->
    $el = $(this.el)

  addScene: ->
    @scene = App.sceneList().createScene()

  addKeyframe: ->
    App.keyframeList().createKeyframe()

  showActionLibrary: ->
    definitions = new App.Collections.ActionDefinitionsCollection()
    definitions.fetch
      success: ->
        defaultAction = new App.Models.Action
          definition: definitions.first()
          attributes: definitions.first().get('attribute_definitions')
          scene: App.currentScene()

        formView = new App.Views.NewAction(model: defaultAction)
        libraryView = new App.Views.ActionIndex(actions: definitions, formView: formView)
        App.modalWithView(view: libraryView).showModal()

  editText: ->
    $("#text").focus() unless $('.edit-text').hasClass "disabled"

  showImageLibrary: ->
    @loadDataFor("image")

  showVideoLibrary: ->
    @loadDataFor("video")

  showFontLibrary: ->
    @loadDataFor("font")

  showSoundLibrary: ->
    @loadDataFor("sound")

  loadDataFor: (assetType) ->
    @assetLibraryView.activeAssetType = assetType
    App.modalWithView(view: @assetLibraryView).showModal()
    @assetLibraryView.setAllowedFilesFor assetType + "s"
    @assetLibraryView.initAssetLibFor assetType + "s"

