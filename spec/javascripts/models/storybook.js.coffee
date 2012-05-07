describe "App.Models.Storybook", ->
  beforeEach ->
    @storybook = new App.Models.Storybook()

  it "should be defined", ->
    expect(App.Models.Storybook).toBeDefined()

  it "can be instantiated", ->
    expect(@storybook).not.toBeNull()