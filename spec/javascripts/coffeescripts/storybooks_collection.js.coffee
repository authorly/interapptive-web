describe "App.Collections.StorybooksCollection", ->

  it "should be defined", ->
    expect(App.Collections.StorybooksCollection).toBeDefined();

  it "can be instantiated", ->
    storybooksCollection = new App.Collections.StorybooksCollection()
    expect(storybooksCollection).not.toBeNull()