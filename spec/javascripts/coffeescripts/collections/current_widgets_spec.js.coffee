describe "App.Collections.CurrentWidgetsCollection", ->
  beforeEach ->
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  it 'should be sorted correctly: first SpriteWidgets sorted by z_order, then buttons sorted by z_order, then Hotspots sorted by their id',  ->
    widgets = new App.Collections.CurrentWidgets([
      new App.Models.SpriteWidget(name: 'sprite_1', z_order: 3),
      new App.Models.SpriteWidget(name: 'sprite_2', z_order: 1),
      new App.Models.ButtonWidget(name: 'button_1', z_order: 4002),
      new App.Models.ButtonWidget(name: 'button_2', z_order: 4001),
      new App.Models.ButtonWidget(name: 'home',     z_order: 4004),
      new App.Models.HotspotWidget(name: 'hotspot_1', id: 5001),
      new App.Models.HotspotWidget(name: 'hotspot_2', id: 5000),
    ])
    expect(widgets.map (w) -> w.get('name')).toEqual ['sprite_2', 'sprite_1', 'button_2', 'button_1', 'home', 'hotspot_2', 'hotspot_1']

  describe 'change current keyframe', ->
    beforeEach ->
      @widgets = new App.Collections.CurrentWidgets
      expect(@widgets.length).toEqual 0

      @home = new App.Models.ButtonWidget(name: 'home')
      @storybook = new App.Models.Storybook {
        widgets: [@home]
      }, parse: true

      @rim  = new App.Models.ButtonWidget(name: 'read_it_myself')
      @rtm  = new App.Models.ButtonWidget(name: 'read_to_me')
      @auto = new App.Models.ButtonWidget(name: 'auto_play')
      @s0 = new App.Models.SpriteWidget
      @main_menu = new App.Models.Scene {
        is_main_menu: true
        widgets: [@rtm, @rim, @auto, @s0]
        storybook: @storybook
      }, parse: true

      @o0 = new App.Models.SpriteOrientation
      @main_menu_keyframe = new App.Models.Keyframe {
        scene: @main_menu
        widgets: [@o0]
      }, parse: true


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

    describe 'change to the main menu keyframe', ->
      beforeEach ->
        @widgets.changeKeyframe(@main_menu_keyframe)

      it 'adds scene and keyframe widgets', ->
        expect(@widgets).toContainWidgets [@rtm, @rim, @auto, @s0, @o0]


      describe 'change to a keyframe from a scene', ->

        beforeEach ->
          @widgets.changeKeyframe(@keyframe1)

        it 'removes old widgets and adds keyframe, scene and storybook widgets', ->
          expect(@widgets).toContainWidgets [@home, @h1, @h2, @s1, @t1, @o1]

        it 'adds widgets if they are added to the keyframe', ->
          w = new App.Models.TextWidget
          @keyframe1.widgets.add w
          expect(@widgets).toContainWidgets [@home, @h1, @h2, @s1, @t1, @o1, w]

        it 'removes widgets if they are removed from the keyframe', ->
          @keyframe1.widgets.remove @t1
          expect(@widgets).toContainWidgets [@home, @h1, @h2, @s1, @o1]

        it 'adds widgets if they are added to the scene', ->
          w = new App.Models.HotspotWidget
          @keyframe1.scene.widgets.add w
          expect(@widgets).toContainWidgets [@home, @h1, @h2, @s1, @t1, @o1, w]

        it 'removes widgets if they are removed from the scene', ->
          @keyframe1.scene.widgets.remove @h1
          expect(@widgets).toContainWidgets [@home, @h2, @s1, @t1, @o1]

        describe 'moving to the same scene', ->
          it 'removes old keyframe widgets and adds new keyframe widgets', ->
            @widgets.changeKeyframe(@keyframe2)
            expect(@widgets).toContainWidgets [@home, @o2, @h1, @h2, @s1]

        describe 'moving to another scene', ->
          beforeEach ->
            @widgets.changeKeyframe(@keyframe2_1)
            @expectedWidgets = [@home, @h2_1, @t2_1]

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

        describe 'moving to the main menu scene', ->
          beforeEach ->
            @widgets.changeKeyframe(@main_menu_keyframe)

          it 'removes old keyframe, scene and storybook widgets and adds new scene & keyframe widgets', ->
            expect(@widgets).toContainWidgets [@rtm, @rim, @auto, @s0, @o0]
