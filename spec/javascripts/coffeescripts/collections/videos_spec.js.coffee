describe "App.Collections.VideosCollection", ->
  beforeEach ->
    storybook = new App.Models.Storybook(id: 1)
    scene = new App.Models.Scene({}, { collection: storybook.scenes })
    @collection = new App.Collections.VideosCollection([], { storybook: storybook })

  it "should have url based on current storybook", ->
    expect(@collection.url()).toEqual("/storybooks/" + @collection.storybook.get('id') + "/videos.json")

  describe "#toSelectOptionGroup", ->
    xit "should call the callback function with model toSelectOption"
