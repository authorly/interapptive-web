describe "App.Models.Keyframe", ->

  beforeEach ->
    @server = sinon.fakeServer.create()
    @storybook = new App.Models.Storybook(id: 1)

    @scene = new App.Models.Scene({
      id: 1,
      image_id: 1,
      sound_id: 2,
      preview_image_id: 3,
      position: 1,
      content_highlight_times: [1, 2, 3, 4],
    },
    {
      collection: @storybook.scenes
    })


    @keyframe = new App.Models.Keyframe scene: @scene


  afterEach ->
    @server.restore()

  it 'knows its text widgets', ->
    @keyframe.widgets.add [type: 'TextWidget']
    @keyframe.widgets.add [type: 'HotspotWidget']

    expect(@keyframe.textWidgets().length).toEqual(1)


  describe 'widgets', ->
    beforeEach ->
      @widgets = @keyframe.widgets

    describe 'z_order', ->
      it 'should be the default for texts', ->
        @widgets.add [type: 'TextWidget']
        expect(@widgets.at(0).get('z_order')).toEqual (new App.Models.TextWidget).get('z_order')

      it 'should be equal with the number of texts when adding subsequent texts', ->
        @widgets.add [type: 'SpriteOrientation']
        @widgets.add [type: 'TextWidget']
        @widgets.add [type: 'TextWidget']
        @widgets.add [type: 'TextWidget']
        expect(@widgets.at(3).get('z_order')).toEqual (new App.Models.TextWidget).get('z_order') + 2

      it 'should be the default for HotspotWidgets', ->
        @widgets.add [type: 'HotspotWidget']
        expect(@widgets.at(0).get('z_order')).toEqual (new App.Models.HotspotWidget).get('z_order')

      it 'should be equal with the number of hotspots when adding subsequent hotspots', ->
        @widgets.add [type: 'HotspotWidget']
        @widgets.add [type: 'TextWidget']
        @widgets.add [type: 'SpriteOrientation']
        @widgets.add [type: 'HotspotWidget']
        expect(@widgets.at(3).get('z_order')).toEqual (new App.Models.HotspotWidget).get('z_order') + 1
