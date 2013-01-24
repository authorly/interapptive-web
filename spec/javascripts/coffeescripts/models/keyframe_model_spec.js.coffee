xdescribe "App.Models.Keyframe", ->

  # TODO: WA: Following tests should be enabled only when
  # App.Models.Scene#spriteWidgets() function is working
  beforeEach ->
    @storybook = new App.Models.Storybook(id: 1)
    @scene = new App.Models.Scene({ id: 1 }, { collection: @storybook.scenes })

    @keyframe = new App.Models.Keyframe(
      background_x_coord: 512,
      background_y_coord: 386,
      preview_image_id: 3,
      scene: @scene
    )
    App.currentSelection.get('scene')
    App.currentSelection.get('keyframe')

  it "should be defined", ->
    expect(App.Models.Keyframe).toBeDefined()

  it "can be instantiated", ->
    keyframe = new App.Models.Keyframe()
    expect(keyframe).not.toBeNull()

  describe "when instantiated", ->
    it "should expose the background image x coordinate attribute", ->
      expect(@keyframe.get("background_x_coord")).toEqual 512

    it "should expose the background image y coordinate attribute", ->
      expect(@keyframe.get("background_y_coord")).toEqual 386

    it "should expose the background image's id attribute", ->
      expect(@keyframe.get("image_id")).toEqual 3


  describe "#save", ->
    beforeEach ->
      @server = sinon.fakeServer.create()

    afterEach ->
      @server.restore()

    it "sends valid data to the server", ->
      @keyframe.save page_number: 2
      request = @server.requests[0]
      keyframe_response = JSON.parse(request.requestBody)
      expect(keyframe_response).toBeDefined()
      expect(keyframe_response.page_number).toEqual 2

    describe "request", ->
      describe "on create", ->
        beforeEach ->

          @keyframe.save(position: 2)
          @request = @server.requests[0]

        it "should be POST", ->
          #expect(@request).toBePOST()

        it "should be async", ->
          expect(@request).toBeAsync()

        it "should have valid url", ->
          expect(@request).toHaveUrl("/scenes/1/keyframes/1.json")

      describe "on update", ->
        beforeEach ->
          @keyframe.save(id: 3)
          @request = @server.requests[0]

        it "should be PUT", ->
          expect(@request).toBePUT()

        it "should be async", ->
          expect(@request).toBeAsync()

        it "should have valid url", ->
          expect("/scenes/1/keyframes/#{@keyframe.get("id")}.json").toEqual "/scenes/1/keyframes/3.json"
