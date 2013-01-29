describe "App.Collections.FontsCollection", ->
  beforeEach ->
    storybook = new App.Models.Storybook(id: 1)
    scene = new App.Models.Scene({}, { collection: storybook.scenes })

    App.currentSelection.set(storybook: storybook)
    App.currentSelection.set(scene: scene)
    @collection = new App.Collections.FontsCollection({ storybook: storybook })

  it "should have url based on current storybook", ->
    expect(@collection.url()).toEqual("/storybooks/" + App.currentSelection.get('storybook').get('id') + "/fonts.json")
