describe "App.Views.FileMenuView", ->
  beforeEach ->
    @file_menu_view = new App.Views.FileMenuView()

  describe '#toggleFontEditorPalette', ->
    it 'triggers toggle event on textEditorPalette', ->
      spyOn(App.textEditorPalette, 'trigger')
      @file_menu_view.toggleFontEditorPalette()
      expect(App.textEditorPalette.trigger).toHaveBeenCalledWith('toggle')
