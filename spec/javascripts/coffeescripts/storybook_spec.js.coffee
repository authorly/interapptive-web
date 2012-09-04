describe "App.Views.Storybook", ->

  beforeEach ->
    @storybook = new App.Models.Storybook(
      title: "Wake up"
      id: 7
    )
    @storybookView = new App.Views.Storybook(model: @storybook)

  it "can render an individual storybook", ->
    $el = $(@storybookView.render().el)
    expect($el).toHaveText /Wake up/