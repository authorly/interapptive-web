class App.Views.FileMenuView extends Backbone.View
  events:
    'click .show-storybook-settings': 'showSettings'
    'click .show-storybook-icons':    'showAppIcons'
    'click .toggle-scene-images':     'toggleSceneImagesPalette'
    'click .compile-storybook':       'compileStorybook'
    'click .toggle-font-editor':      'toggleFontEditorPalette'
    'click .switch-storybook':        'switchStorybook'
    'click .about-authorly':          'showAbout'
    'click .reset-palettes':          'resetPalettes'
    'click .images':                  'showImageLibrary'
    'click .videos':                  'showVideoLibrary'
    'click .fonts':                   'showFontLibrary'
    'click .sounds':                  'showSoundLibrary'


  initialize: ->
    App.vent.on 'show:imageLibrary', @showImageLibrary, @


  switchStorybook: ->
    document.location.reload(true)


  showAbout: ->
    view = new App.Views.AboutView()
    App.modalWithView(view: view).show()


  compileStorybook: (event) ->
    App.currentSelection.get('storybook').compile($(event.currentTarget).data('platform'))


  toggleSceneImagesPalette: ->
    App.vent.trigger('toggle:palette', 'sceneImages')


  toggleFontEditorPalette: ->
    App.vent.trigger('toggle:palette', 'fontEditor')


  resetPalettes: ->
    App.vent.trigger('reset:palettes')


  showImageLibrary: -> @loadDataFor 'image'


  showVideoLibrary: -> @loadDataFor 'video'


  showFontLibrary:  -> @loadDataFor 'font'


  showSoundLibrary: -> @loadDataFor 'sound'


  loadDataFor: (assetType) ->
    storybook = App.currentSelection.get('storybook')
    if assetType is 'font'
      view = new App.Views.AssetLibrary(assetType: assetType, assets: storybook.customFonts())
    else
      view = new App.Views.AssetLibrary(assetType: assetType, assets: storybook[assetType + 's'])

    App.modalWithView(view: view).show()
