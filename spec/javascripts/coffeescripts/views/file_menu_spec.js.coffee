describe "App.Views.FileMenuView", ->
  beforeEach ->
    @file_menu_view = new App.Views.FileMenuView()

  describe '#toggleFontEditorPalette', ->
    it 'triggers toggle event on App.vent', ->
      spyOn(App.vent, 'trigger')
      @file_menu_view.toggleFontEditorPalette()
      expect(App.vent.trigger).toHaveBeenCalledWith('toggle:palette', 'textEditorPalette')
