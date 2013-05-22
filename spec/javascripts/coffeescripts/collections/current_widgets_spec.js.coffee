describe "App.Collections.CurrentWidgetsCollection", ->
  beforeEach ->
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  it 'should be sorted correctly: first SpriteWidgets sorted by z_order, then Hotspots sorted by their id', ->
    widgets = new App.Collections.CurrentWidgets([
      new App.Models.SpriteWidget(name: 'sprite_1', z_order: 3),
      new App.Models.ButtonWidget(name: 'sprite_2', z_order: 1),
      new App.Models.HotspotWidget(name: 'hotspot_1', id: 2001),
      new App.Models.HotspotWidget(name: 'hotspot_2', id: 2000),
    ])
    expect(widgets.map (w) -> w.get('name')).toEqual ['sprite_2', 'sprite_1', 'hotspot_2', 'hotspot_1']

  describe 'change current keyframe', ->
    beforeEach ->
      @widgets = new App.Collections.CurrentWidgets
      expect(@widgets.length).toEqual 0

      @storybook = new App.Models.Storybook
      @h1 = new App.Models.HotspotWidget
      @h2 = new App.Models.HotspotWidget
      @s1 = new App.Models.SpriteWidget
      @scene1 = new App.Models.Scene {
        widgets: [@h1, @h2, @s1]
        storybook: @storybook
      }, parse: true

      @t1 = new App.Models.TextWidget
      @o1 = new App.Models.SpriteOrientation
      @keyframe1 = new App.Models.Keyframe {
        scene: @scene1
        widgets: [@t1, @o1]
      }, parse: true

      @o2 = new App.Models.SpriteOrientation
      @keyframe2 = new App.Models.Keyframe {
        scene: @scene1
        widgets: [@o2]
      }, parse: true


      @h2_1 = new App.Models.HotspotWidget
      @scene2 = new App.Models.Scene {
        widgets: [@h2_1]
        storybook: @storybook
      }, parse: true

      @t2_1 = new App.Models.TextWidget
      @keyframe2_1 = new App.Models.Keyframe {
        scene: @scene2
        widgets: [@t2_1]
      }, parse: true

      @widgets.changeKeyframe(@keyframe1)

    it 'adds keyframe & scene widgets', ->
      expect(@widgets).toContainWidgets [@h1, @h2, @s1, @t1, @o1]

    it 'adds widgets if they are added to the keyframe', ->
      w = new App.Models.TextWidget
      @keyframe1.widgets.add w
      expect(@widgets).toContainWidgets [@h1, @h2, @s1, @t1, @o1, w]

    it 'removes widgets if they are removed from the keyframe', ->
      @keyframe1.widgets.remove @t1
      expect(@widgets).toContainWidgets [@h1, @h2, @s1, @o1]

    it 'adds widgets if they are added to the scene', ->
      w = new App.Models.HotspotWidget
      @keyframe1.scene.widgets.add w
      expect(@widgets).toContainWidgets [@h1, @h2, @s1, @t1, @o1, w]

    it 'removes widgets if they are removed from the scene', ->
      @keyframe1.scene.widgets.remove @h1
      expect(@widgets).toContainWidgets [@h2, @s1, @t1, @o1]

    describe 'moving to the same scene', ->
      it 'removes old keyframe widgets and adds new keyframe widgets', ->
        @widgets.changeKeyframe(@keyframe2)
        expect(@widgets).toContainWidgets [@o2, @h1, @h2, @s1]

      describe 'moving to another scene', ->
        beforeEach ->
          @widgets.changeKeyframe(@keyframe1)
          @widgets.changeKeyframe(@keyframe2_1)
          @expectedWidgets = [@h2_1, @t2_1]

        it 'removes old keyframe & scene widgets and adds new scene & keyframe widgets', ->
          expect(@widgets).toContainWidgets @expectedWidgets

        it 'does not add widgets if they are added to the old keyframe', ->
          @keyframe1.widgets.add(new App.Models.TextWidget)
          expect(@widgets).toContainWidgets @expectedWidgets

        it 'does not remove widgets if they are removed from the old keyframe', ->
          @keyframe1.widgets.remove @keyframe1.widgets.at(0)
          expect(@widgets).toContainWidgets @expectedWidgets

        it 'does not add widgets if they are added to the old scene', ->
          @keyframe1.scene.widgets.add(new App.Models.HotspotWidget)
          expect(@widgets).toContainWidgets @expectedWidgets

        it 'does not remove widgets if they are removed from the old scene', ->
          @keyframe1.scene.widgets.remove @keyframe1.scene.widgets.at(0)
          expect(@widgets).toContainWidgets @expectedWidgets
