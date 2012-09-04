describe "App.Views.StorybookIndex", ->

  beforeEach ->
    @storybookCollection = new App.Collections.StorybooksCollection()
    @view = new App.Views.StorybookIndex(collection: @storybookCollection)

  describe "Instantiation", ->
    it "should create a container for the list element", ->
      expect(@view.el.nodeName).toEqual "DIV"
