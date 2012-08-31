describe "App.Collections.ScenesCollection", ->

  it "should be defined", ->
    expect(App.Collections.ScenesCollection).toBeDefined();

  it "can be instantiated", ->
    scenesCollection = new App.Collections.ScenesCollection([], {storybook_id: 1})
    expect(scenesCollection).not.toBeNull()