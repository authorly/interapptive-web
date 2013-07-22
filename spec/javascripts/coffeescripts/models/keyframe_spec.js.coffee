describe "App.Models.Keyframe", ->

  beforeEach ->
    @server = sinon.fakeServer.create()
    @storybook = new App.Models.Storybook(id: 1)

    @scene = new App.Models.Scene({
      id: 1,
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

  describe 'autoplay duration', ->

    it 'is 8 seconds if there is no text', ->
      expect(@keyframe.autoplayDuration()).toEqual 8

    describe 'when there is text', ->

      it 'is computed from the text widgets, at 45 words/minute reading speed, if there is no voiceover', ->
        @keyframe.widgets.add [
          {type: 'TextWidget'},
          {type: 'TextWidget'},
          {type: 'TextWidget'}
        ]
        sinon.stub(@keyframe.widgets.at(0), 'wordCount').returns(2)
        sinon.stub(@keyframe.widgets.at(1), 'wordCount').returns(9)
        sinon.stub(@keyframe.widgets.at(2), 'wordCount').returns(5)
        expect(@keyframe.autoplayDuration()).toEqual 21


      it 'is the duration of the voiceover sound, if the sound exists', ->
        @storybook.sounds.add(voiceover = new App.Models.Sound(duration: 17.2, id: 1981))
        @keyframe.widgets.add type: 'TextWidget'
        @keyframe.set voiceover_id: voiceover.id

        expect(@keyframe.autoplayDuration()).toEqual 17.2

      it "is is computed from the text widgets if the voiceover sound exists but its duration isn't available", ->
        @storybook.sounds.add(voiceover = new App.Models.Sound(duration: null, id: 1981))
        @keyframe.set voiceover_id: voiceover.id
        @keyframe.widgets.add type: 'TextWidget'
        sinon.stub(@keyframe.widgets.at(0), 'wordCount').returns(15)

        expect(@keyframe.autoplayDuration()).toEqual 20

