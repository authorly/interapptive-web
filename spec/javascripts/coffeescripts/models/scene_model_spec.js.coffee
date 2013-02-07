describe "App.Models.Scene", ->

  beforeEach ->
    @server = sinon.fakeServer.create()
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


  afterEach ->
    @server.restore()


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


  describe 'widgets', ->
    beforeEach ->
      @widgets = @scene.widgets

    describe 'removal', ->
      it 'should not allow removing ButtonWidgets', ->
        @widgets.add [type: 'ButtonWidget']
        @widgets.remove @widgets.at(0)
        expect(@widgets.length).toEqual 1

    describe 'z_order', ->
      it 'should be 1 when adding the first SpriteWidget', ->
        @widgets.add [type: 'SpriteWidget']
        expect(@widgets.at(0).get('z_order')).toEqual 1

      it 'should be the default for HotspotWidgets', ->
        @widgets.add [type: 'HotspotWidget']
        expect(@widgets.at(0).get('z_order')).toEqual (new App.Models.HotspotWidget).get('z_order')

      it 'should be equal with the number of sprites when adding subsequent SpriteWidgets', ->
        @widgets.add [type: 'HotspotWidget']
        @widgets.add [type: 'SpriteWidget']
        @widgets.add [type: 'SpriteWidget']
        expect(@widgets.at(2).get('z_order')).toEqual 2


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
