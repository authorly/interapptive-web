describe "App.Collections.KeyframesCollection", ->

  it "should be defined", ->
    expect(App.Collections.KeyframesCollection).toBeDefined();

  it "can be instantiated", ->
    keyframesCollection = new App.Collections.KeyframesCollection([], {scene_id: 1})
    expect(keyframesCollection).not.toBeNull()