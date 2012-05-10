describe "Interapptive", ->
  it "has a namespace for Models", ->
    expect(App.Models).toBeTruthy()

  it "has a namespace for Collections", ->
    expect(App.Collections).toBeTruthy()

  it "has a namespace for Views", ->
    expect(App.Views).toBeTruthy()

  it "has a namespace for Routers", ->
    expect(App.Routers).toBeTruthy()

  describe "initialize()", ->
    it "accepts data JSON and instantiates a collection from it", ->
      data =
        storybooks: [
          title: "thing to do"
        ,
          title: "another thing"
        ]
        users: [
          id: "1"
          email: "alice@example.com"
        ]

      App.initialize
      App.storybooks = data
      expect(App.storybooks.storybooks).not.toEqual `undefined`
      expect(App.storybooks.storybooks.length).toEqual 2
      expect(App.storybooks.storybooks[0].title).toEqual "thing to do"
      expect(App.storybooks.storybooks[1].title).toEqual "another thing"