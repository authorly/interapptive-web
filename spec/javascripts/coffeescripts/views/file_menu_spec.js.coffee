describe "App.Views.FileMenuView", ->
  beforeEach ->
    @file_menu_view = new App.Views.FileMenuView()
    sinon.spy App.vent, 'trigger'

  afterEach ->
    App.vent.trigger.restore()

  describe '#toggleFontEditorPalette', ->
    it 'triggers toggle event on App.vent', ->
      @file_menu_view.toggleFontEditorPalette()
      expect(App.vent.trigger).toHaveBeenCalledWith('toggle:palette', 'fontEditor')

  describe '#toggleSceneImagesPalette', ->
    it 'triggers toggle event on App.vent', ->
      @file_menu_view.toggleSceneImagesPalette()
      expect(App.vent.trigger).toHaveBeenCalledWith('toggle:palette', 'sceneImages')
