# TODO: WA: Following tests should be enabled only when
# App.Models.Scene#spriteWidgets() function is working
describe "App.Models.Keyframe", ->

  beforeEach ->
    @server = sinon.fakeServer.create()
    @storybook = new App.Models.Storybook(id: 1)

    @scene = new App.Models.Scene({
      id: 1,
      image_id: 1,
      sound_id: 2,
      preview_image_id: 3,
      page_number: 1
    },
    {
      collection: @storybook.scenes
    })


    @keyframe = new App.Models.Keyframe({
      id: 100,
      scene: @scene
    })
    App.currentSelection.get('scene')
    App.currentSelection.get('keyframe')


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
          expect(@request).toHaveUrl("/scenes/1/keyframes/100.json")

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


  describe 'widgets', ->

    it 'can filter widgets by class', ->
      @keyframe.widgets.add [type: 'ButtonWidget']
      @keyframe.widgets.add [type: 'SpriteWidget']

      expect(@keyframe.widgets.length).toEqual(2)
      console.log @keyframe.widgets
      expect(@keyframe.widgetsByClass(App.Models.SpriteWidget).length).toEqual(2)
      expect(@keyframe.widgetsByClass(App.Models.ButtonWidget).length).toEqual(1)
      expect(@keyframe.widgetsByClass(App.Models.HotspotWidget).length).toEqual(0)

    it 'knows its text widgets', ->
      @keyframe.widgets.add [type: 'TextWidget']
      @keyframe.widgets.add [type: 'SpriteWidget']

      expect(@keyframe.textWidgets().length).toEqual(1)
