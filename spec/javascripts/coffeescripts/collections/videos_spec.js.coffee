describe "App.Collections.VideosCollection", ->
  beforeEach ->
    storybook = new App.Models.Storybook(id: 1)
    scene = new App.Models.Scene({}, { collection: storybook.scenes })
    @collection = new App.Collections.VideosCollection([], { storybook: storybook })

  it "should have url based on its storybook", ->
    expect(@collection.url()).toEqual("/storybooks/" + @collection.storybook.get('id') + "/videos.json")
