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

  it "should be defined", ->
    expect(App.Models.Storybook).toBeDefined()

  it "can be instantiated", ->
    expect(@storybook).not.toBeNull()

  describe "when instantiated", ->
    it "should expose the model's title attribute", ->
      expect(@storybook.get("title")).toEqual "Storybook Title"

    it "should expose the model's price attribute", ->
      expect(@storybook.get("price")).toEqual 3.99

    it "should expose the model's author attribute", ->
      expect(@storybook.get("author")).toEqual "Author Write"

    it "should expose the model's description attribute", ->
      expect(@storybook.get("description")).toEqual "Storybook app description"

    it "should expose the model's publish date attribute", ->
      expect(@storybook.get("published_on")).toEqual "2012-08-19 08:09:27"

    it "should expose an attribute for setting target platform for compilation", ->
      expect(@storybook.get("android_or_ios")).toEqual "both"

    it "should expose the model's  voice recording option attribute", ->
      expect(@storybook.get("record_enabled")).toEqual true

  describe "attribute validation", ->
    beforeEach ->
      storybook = new App.Models.Storybook()
      App.currentStorybook(storybook)
      form = new App.Views.Storybooks.SettingsForm().form
      @errors = form.commit()

    it "should require a title", ->
      expect(@errors.title.message).toEqual "Required"

    it "should require a price", ->
      expect(@errors.price.message).toEqual "Required"

    it "should require a description", ->
      expect(@errors.description.message).toEqual "Required"

    it "should require a author", ->
      expect(@errors.author.message).toEqual "Required"

  describe "#save", ->
    beforeEach ->
      @server = sinon.fakeServer.create()

    afterEach ->
      @server.restore()

    it "sends valid data to the server", ->
      @storybook.save title: "A new storybook title"
      request = @server.requests[0]
      storybook_response = JSON.parse(request.requestBody)
      expect(storybook_response).toBeDefined()
      expect(storybook_response.title).toEqual "A new storybook title"
      
    describe "request", ->
      describe "on create", ->
        beforeEach ->
          @storybook.id = null
          @storybook.save()
          @request = @server.requests[0]

        it "should be POST", ->
          expect(@request).toBePOST()

        it "should be async", ->
          expect(@request).toBeAsync()

        it "should have valid url", ->
          expect(@request).toHaveUrl('/storybooks.json')

      describe "on update", ->
        beforeEach ->
          @storybook.id = 3
          @storybook.save()
          @request = @server.requests[0]

        it "should be PUT", ->
          expect(@request).toBePUT()

        it "should be async", ->
          expect(@request).toBeAsync()
