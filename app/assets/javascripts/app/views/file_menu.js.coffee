class App.Views.FileMenuView extends Backbone.View
  events:
    'click .toggle-scene-images':     'toggleSceneImagesPalette'
    'click .compile-storybook':       'compileStorybook'
    'click .toggle-font-editor':      'toggleFontEditorPalette'
    'click .switch-storybook':        'switchStorybook'


  initialize: ->
    App.vent.on 'show:imageLibrary', @showImageLibrary, @


  switchStorybook: ->
    document.location.reload(true)


  showAbout: ->
    view = new App.Views.AboutView()
    App.modalWithView(view: view).show()
