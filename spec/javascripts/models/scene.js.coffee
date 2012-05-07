describe "App.Models.Scene", ->

  it "should be defined", ->
    expect(App.Models.Scene).toBeDefined()

  it "can be instantiated", ->
    scene = new App.Models.Scene()
    expect(scene).not.toBeNull()