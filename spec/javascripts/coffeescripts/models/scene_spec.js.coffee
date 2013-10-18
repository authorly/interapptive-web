describe "App.Models.Scene", ->

  beforeEach ->
    @server = sinon.fakeServer.create()
    @storybook = new App.Models.Storybook(id: 1)

    @scene = new App.Models.Scene({},
      {
        collection: @storybook.scenes
      })


  afterEach ->
    @server.restore()


  describe 'widgets', ->
    beforeEach ->
      @widgets = @scene.widgets

    describe 'removal', ->
      it 'should not allow removing ButtonWidgets', ->
        @widgets.add [type: 'ButtonWidget']
        @widgets.remove @widgets.at(0)
        expect(@widgets.length).toEqual 1

      it 'should allow removing other kinds of widgets', ->
        @widgets.add [type: 'SpriteWidget']
        @widgets.remove @widgets.at(0)
        expect(@widgets.length).toEqual 0

    describe 'z_order', ->
      it 'should be 1 when adding the first SpriteWidget', ->
        @widgets.add [type: 'SpriteWidget']
        expect(@widgets.at(0).get('z_order')).toEqual 1

      it 'should be equal with the number of sprites when adding subsequent SpriteWidgets', ->
        @widgets.add [type: 'SpriteWidget']
        @widgets.add [type: 'SpriteWidget']
        @widgets.add [type: 'SpriteWidget']
        expect(@widgets.at(2).get('z_order')).toEqual 3

    describe 'reordering', ->
      it 'should determine only one save of the scene', ->
        @widgets.add [
          { z_index: 1, id: 1, type: 'SpriteWidget' },
          { z_index: 2, id: 2, type: 'SpriteWidget' }
          { z_index: 3, id: 3, type: 'SpriteWidget' }
        ], {silent: true}
        @widgets.get(1).set z_index: 2
        @widgets.get(2).set z_index: 3
        @widgets.get(3).set z_index: 1
        saves = _.filter @server.requests, (r) => r.url == @scene.url()
        expect(saves.length).toEqual 1


  describe 'abilities', ->

    describe 'add text', ->
      it 'can if normal scene', ->
        expect(@scene.canAddText()).toEqual true

      it 'can not if main menu', ->
        @scene.set is_main_menu: true
        expect(@scene.canAddText()).toEqual false

    describe 'add keyframes', ->
      it 'can if normal scene', ->
        expect(@scene.canAddKeyframes()).toEqual true

      it 'can not if main menu', ->
        @scene.set is_main_menu: true
        expect(@scene.canAddKeyframes()).toEqual false

    describe 'add an animation keyframe', ->
      it 'can if normal scene without animation', ->
        stub = sinon.stub()
        stub.returns(false)

        @scene.keyframes = {animationPresent: stub }
        expect(@scene.canAddAnimationKeyframe()).toEqual true

      it 'can not if normal scene with animation', ->
        stub = sinon.stub()
        stub.returns(true)

        @scene.keyframes = {animationPresent: stub }
        expect(@scene.canAddAnimationKeyframe()).toEqual false

      it 'can not if main menu', ->
        @scene.set is_main_menu: true
        expect(@scene.canAddAnimationKeyframe()).toEqual false


  describe 'listeners', ->

    it 'proxies image removal to the widgets', ->
      listener = sinon.spy @scene.widgets, 'imageRemoved'
      @storybook.images.trigger 'remove'
      expect(listener).toHaveBeenCalled()

