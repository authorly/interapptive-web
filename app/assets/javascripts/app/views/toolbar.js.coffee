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
        action = new App.Models.Action
          definition: definitions.first()
          attributes: definitions.first().get('attribute_definitions')
          scene: App.currentScene()

        view = new App.Views.NewAction(model: action, definitions: definitions)
        App.modalWithView(view: view).showModal()

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

