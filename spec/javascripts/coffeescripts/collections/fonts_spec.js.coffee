describe "App.Collections.FontsCollection", ->
  beforeEach ->
    storybook = new App.Models.Storybook(id: 1)
    @collection = new App.Collections.FontsCollection([], {storybook: storybook})

  it "should have url based on its storybook", ->
    expect(@collection.url()).toEqual("/storybooks/1/fonts.json")
