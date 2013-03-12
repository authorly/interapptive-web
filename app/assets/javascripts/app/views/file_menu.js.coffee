class App.Views.FileMenuView extends Backbone.View
  events:
    'click .show-storybook-settings': 'showSettings'
    'click .show-storybook-icons':    'showAppIcons'
    'click .toggle-image-editor':     'toggleImageEditorPalette'
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


  render: ->
    @


  switchStorybook: ->
    document.location.reload(true)


  showSettings: ->
    view = new App.Views.Storybooks.SettingsForm()
    App.modalWithView(view: view).show()


  showAbout: ->
    view = new App.Views.AboutView()
    App.modalWithView(view: view).show()


  showAppIcons: ->
    view = new App.Views.Storybooks.AppIcons(storybook: App.currentSelection.get('storybook'))
    App.modalWithView(view: view).show()


  compileStorybook: ->
    App.currentSelection.get('storybook').compile()


  toggleImageEditorPalette: ->
    App.vent.trigger('toggle:palette', 'imageEditor')


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
    view = new App.Views.AssetLibrary assetType, storybook[assetType + 's']

    App.modalWithView(view: view).show()
