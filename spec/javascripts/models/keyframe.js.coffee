describe "App.Models.Keyframe", ->

  it "should be defined", ->
    expect(App.Models.Keyframe).toBeDefined()

  it "can be instantiated", ->
    keyframe = new App.Models.Keyframe()
    expect(keyframe).not.toBeNull()