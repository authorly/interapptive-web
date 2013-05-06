describe "App.Models.Storybook", ->

  beforeEach ->
    @storybook = new App.Models.Storybook(
                                  title: "Storybook Title",
                                  price: 3.99,
                                  author: "Author Write",
                                  description: "Storybook app description",
                                  published_on: "2012-08-19 08:09:27",
                                  android_or_ios: "both",
                                  record_enabled: true
                                )

