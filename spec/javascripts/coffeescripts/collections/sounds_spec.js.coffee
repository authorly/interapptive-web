describe "App.Collections.SoundsCollection", ->
  beforeEach ->
    storybook = new App.Models.Storybook(id: 1)
    scene = new App.Models.Scene({}, { collection: storybook.scenes })

    @collection = new App.Collections.SoundsCollection([], { storybook: storybook })

  it "should have url based on its storybook", ->
    expect(@collection.url()).toEqual("/storybooks/" + @collection.storybook.get('id') + "/sounds.json")
