describe "App.Models.Scene", ->

  beforeEach ->
    @storybook = new App.Models.Storybook(id: 1)

    @scene = new App.Models.Scene({
        image_id: 1,
        sound_id: 2,
        preview_image_id: 3,
        page_number: 1
      },
      {
        collection: @storybook.scenes
      })


  it "should be defined", ->
    expect(App.Models.Scene).toBeDefined()


  describe "when instantiated", ->
    it "should expose the background image id attribute", ->
      expect(@scene.get("image_id")).toEqual 1

    it "should expose the sound_id attribute", ->
      expect(@scene.get("sound_id")).toEqual 2

    it "should expose the preview_image_id attribute", ->
      expect(@scene.get("preview_image_id")).toEqual 3

    it "should expose the page number attribute", ->
      expect(@scene.get("page_number")).toEqual 1


  describe "#save", ->
    beforeEach ->
      @server = sinon.fakeServer.create()

    afterEach ->
      @server.restore()

    it "sends valid data to the server", ->
      @scene.save page_number: 2
      request = @server.requests[0]
      scene_response = JSON.parse(request.requestBody)
      expect(scene_response).toBeDefined()
      expect(scene_response.page_number).toEqual 2

    describe "request", ->
      describe "on create", ->
        beforeEach ->

          @scene.save()
          @request = @server.requests[0]

        it "should be POST", ->
          expect(@request).toBePOST()

        it "should be async", ->
          expect(@request).toBeAsync()

        it "should have valid url", ->
          expect(@request).toHaveUrl('/storybooks/1/scenes.json')

      describe "on update", ->
        beforeEach ->
          @scene.set("id", 3)
          @scene.save()
          @request = @server.requests[0]

        it "should be PUT", ->
          expect(@request).toBePUT()

        it "should be async", ->
          expect(@request).toBeAsync()

        it "should have valid url", ->
          expect("/storybooks/#{@storybook.get("id")}/scenes/#{@scene.get("id")}.json").toEqual "/storybooks/1/scenes/3.json"
