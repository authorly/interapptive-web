class App.Views.FileMenuView extends Backbone.View
  events:
    'click .switch-storybook'         : 'switchStorybook'
    'click .show-storybook-settings'  : 'showSettings'
    'click .about-authorly'           : 'showAbout'
    'click .show-storybook-icons'     : 'showAppIcons'
    'click .compile-storybook'        : 'compileStorybook'
    'click .toggle-image-editor'      : 'toggleImageEditorPalette'
    'click .toggle-scene-images'      : 'toggleSceneImagesPalette'
    'click .toggle-font-editor'       : 'toggleFontEditorPalette'
    'click .reset-palettes'           : 'resetPalettes'


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
    #
    # RFCTR:
    #     Needs ventilation
    #
    view = new App.Views.Storybooks.AppIcons(collection: App.imagesCollection)
    App.modalWithView(view: view).show()
    view.fetchImages()


  compileStorybook: ->
    App.currenSelection.get('storybook').compile()


  toggleImageEditorPalette: ->
    App.vent.trigger('toggle:sprite_list_palette')


  toggleSceneImagesPalette: ->
    App.vent.trigger('toggle:sprite_editor_palette')


  toggleFontEditorPalette: ->
    App.vent.trigger('toggle:text_editor_palette')


  resetPalettes: ->
    App.vent.trigger('reset:palettes')
