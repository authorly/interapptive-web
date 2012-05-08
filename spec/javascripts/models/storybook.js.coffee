describe "App.Models.Storybook", ->
  beforeEach ->
    @storybook = new App.Models.Storybook()

  it "should be defined", ->
    expect(App.Models.Storybook).toBeDefined()

  it "can be instantiated", ->
    expect(@storybook).not.toBeNull()
    
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
          expect(@request.method).toEqual "POST"

        it "should be async", ->
          expect(@request.async).toBeTruthy()

        it "should have valid url", ->
          expect(@request.url).toEqual "storybooks"

      describe "on update", ->
        beforeEach ->
          @storybook.id = 66
          @storybook.save()
          @request = @server.requests[0]

        it "should be PUT", ->
          expect(@request.method).toEqual "PUT"

        it "should be async", ->
          expect(@request.async).toBeTruthy()

        it "should have valid url", ->
          expect("/" + @request.url + "/" + @storybook.id + ".json").toEqual "/storybooks/66.json"