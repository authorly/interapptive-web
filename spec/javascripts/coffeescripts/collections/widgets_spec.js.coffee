describe "App.Collections.Widgets", ->

  beforeEach ->
    @widgets = new App.Collections.Widgets

  it 'can filter widgets by class', ->
    @widgets.add [type: 'ButtonWidget']
    @widgets.add [type: 'SpriteWidget']

    expect(@widgets.length).toEqual(2)
    expect(@widgets.byClass(App.Models.ImageWidget).length).toEqual(2)
    expect(@widgets.byClass(App.Models.SpriteWidget).length).toEqual(1)
    expect(@widgets.byClass(App.Models.ButtonWidget).length).toEqual(1)
    expect(@widgets.byClass(App.Models.HotspotWidget).length).toEqual(0)

  it 'has the right containers for each widget type', ->
    containers = App.Collections.Widgets.containers

    expect(containers['HotspotWidget']).toEqual 'keyframe'
    expect(containers['SpriteWidget']).toEqual  'scene'
    expect(containers['TextWidget']).toEqual    'keyframe'

  describe 'z_order', ->
    describe 'setMaxZOrder', ->
      describe 'when there are only sprites', ->
        beforeEach ->
          @s1 = new App.Models.SpriteWidget(z_order: 1)
          @s2 = new App.Models.SpriteWidget(z_order: 2)
          @widgets.add [@s1, @s2]

        it 'changes z_order correctly', ->
          @widgets.setMaxZOrder(@s1)
          expect(@s1.get('z_order')).toEqual 2
          expect(@s2.get('z_order')).toEqual 1

        it 'leaves z_order if already ok', ->
          @widgets.setMaxZOrder(@s2)
          expect(@s1.get('z_order')).toEqual 1
          expect(@s2.get('z_order')).toEqual 2

      describe 'when there are only buttons', ->
        beforeEach ->
          @s1 = new App.Models.ButtonWidget(z_order: 1)
          @s2 = new App.Models.ButtonWidget(z_order: 2)
          @widgets.add [@s1, @s2]

        it 'changes z_order correctly', ->
          @widgets.setMaxZOrder(@s1)
          expect(@s1.get('z_order')).toEqual 2
          expect(@s2.get('z_order')).toEqual 1

        it 'leaves z_order if already ok', ->
          @widgets.setMaxZOrder(@s2)
          expect(@s1.get('z_order')).toEqual 1
          expect(@s2.get('z_order')).toEqual 2


      describe 'when there are sprites and buttons', ->
        beforeEach ->
          @s1 = new App.Models.SpriteWidget(z_order: 1)
          @s2 = new App.Models.SpriteWidget(z_order: 2)
          @s3 = new App.Models.SpriteWidget(z_order: 3)
          @b1 = new App.Models.ButtonWidget(z_order: 4001)
          @b2 = new App.Models.ButtonWidget(z_order: 4002)
          @widgets.add [@s1, @s2, @s3, @b1, @b2]

        it 'leaves z_order if already ok', ->
          @widgets.setMaxZOrder(@b2)
          for z, w of { 1: @s1, 2: @s2, 3: @s3, 4001: @b1, 4002: @b2 }
            expect(w.get('z_order')).toEqual Number(z)


        it 'brings sprite on top of other sprites, behind buttons', ->
          @widgets.setMaxZOrder(@s1)
          for z, w of { 1: @s2, 2: @s3, 3: @s1, 4001: @b1, 4002: @b2 }
            expect(w.get('z_order')).toEqual Number(z)

    describe 'setMinZOrder', ->
      describe 'when there are only sprites', ->
        beforeEach ->
          @s1 = new App.Models.SpriteWidget(z_order: 1)
          @s2 = new App.Models.SpriteWidget(z_order: 2)
          @widgets.add [@s1, @s2]

        it 'changes z_order correctly', ->
          @widgets.setMinZOrder(@s2)
          expect(@s1.get('z_order')).toEqual 2
          expect(@s2.get('z_order')).toEqual 1

        it 'leaves z_order if already ok', ->
          @widgets.setMinZOrder(@s1)
          expect(@s1.get('z_order')).toEqual 1
          expect(@s2.get('z_order')).toEqual 2

      describe 'when there are only buttons', ->
        beforeEach ->
          @s1 = new App.Models.ButtonWidget(z_order: 1)
          @s2 = new App.Models.ButtonWidget(z_order: 2)
          @widgets.add [@s1, @s2]

        it 'changes z_order correctly', ->
          @widgets.setMinZOrder(@s2)
          expect(@s1.get('z_order')).toEqual 2
          expect(@s2.get('z_order')).toEqual 1

        it 'leaves z_order if already ok', ->
          @widgets.setMinZOrder(@s1)
          expect(@s1.get('z_order')).toEqual 1
          expect(@s2.get('z_order')).toEqual 2


      describe 'when there are sprites and buttons', ->
        beforeEach ->
          @s1 = new App.Models.SpriteWidget(z_order: 1)
          @s2 = new App.Models.SpriteWidget(z_order: 2)
          @s3 = new App.Models.SpriteWidget(z_order: 3)
          @b1 = new App.Models.ButtonWidget(z_order: 4001)
          @b2 = new App.Models.ButtonWidget(z_order: 4002)
          @widgets.add [@s1, @s2, @s3, @b1, @b2]

        it 'leaves z_order if already ok', ->
          @widgets.setMinZOrder(@s1)
          for z, w of { 1: @s1, 2: @s2, 3: @s3, 4001: @b1, 4002: @b2 }
            expect(w.get('z_order')).toEqual Number(z)


        it 'brings button under all the other buttons, on top of sprites', ->
          @widgets.setMinZOrder(@b2)
          for z, w of { 1: @s1, 2: @s2, 3: @s3, 4001: @b2, 4002: @b1 }
            expect(w.get('z_order')).toEqual Number(z)

    describe 'z_order validation', ->

      it 'does not allow button widgets before sprite widgets', ->
        order = [
          [1, new App.Models.ButtonWidget],
          [2, new App.Models.SpriteWidget]
        ]
        expect(App.Collections.Widgets.validZOrder(order)).toEqual false


      it 'allows a bunch of sprite widgets, followed by a bunch of button widgets', ->
        order = [
          [1, new App.Models.SpriteWidget],
          [2, new App.Models.SpriteWidget],
          [3, new App.Models.SpriteWidget],
          [4, new App.Models.ButtonWidget],
          [5, new App.Models.ButtonWidget]
        ]

        expect(App.Collections.Widgets.validZOrder(order)).toEqual true


      it 'allows a bunch of sprite widgets', ->
        order = [
          [1, new App.Models.SpriteWidget],
          [2, new App.Models.SpriteWidget]
        ]

        expect(App.Collections.Widgets.validZOrder(order)).toEqual true


      it 'allows a bunch of button widgets', ->
        order = [
          [1, new App.Models.ButtonWidget],
          [2, new App.Models.ButtonWidget]
        ]

        expect(App.Collections.Widgets.validZOrder(order)).toEqual true


      it 'allows an empty collection', ->
        order = []

        expect(App.Collections.Widgets.validZOrder(order)).toEqual true

      it 'does not allow -1 values', ->
        # sometimes z_order gets -1 and cannot figure out how.
        # this is a pathetic attempt to figure out (from user reporting)
        # if this happens while sorting
        # @dira 2014-01-31
        order = [
          [-1, new App.Models.SpriteWidget]
        ]

        expect(App.Collections.Widgets.validZOrder(order)).toEqual false


  describe 'remove asset', ->
    describe 'remove image', ->
      it 'removes all the corresponding sprites with that image', ->
        image = new App.Models.Image id: 3
        @widgets.add [type: 'SpriteWidget', image_id: image.id]
        @widgets.add [type: 'SpriteWidget', image_id: image.id]
        @widgets.add [type: 'SpriteWidget', image_id: image.id]
        @widgets.add [type: 'SpriteWidget']
        @widgets.add [type: 'HotspotWidget']

        @widgets.imageRemoved(image)
        expect(@widgets.length).toEqual 2
        expect(@widgets.where(image_id: image.id).length).toEqual 0


      it 'removes the reference to the image from all buttons that have it', ->
        image = new App.Models.Image id: 3
        @widgets.add [type: 'ButtonWidget', image_id: image.id, selected_image_id: image.id, id: 1]
        anotherId = 4
        @widgets.add [type: 'ButtonWidget', image_id: anotherId, selected_image_id: anotherId, id: 2]
        @widgets.imageRemoved(image)
        expect(@widgets.length).toEqual 2
        w1 = @widgets.get(1)
        expect(w1.get('image_id')).toEqual null
        expect(w1.get('selected_image_id')).toEqual null

        w2 = @widgets.get(2)
        expect(w2.get('image_id')).toEqual anotherId
        expect(w2.get('selected_image_id')).toEqual anotherId


    describe 'remove sound', ->
      it 'removes all the corresponding hotspots with that sound', ->
        sound = new App.Models.Sound id: 3
        @widgets.add [type: 'HotspotWidget', sound_id: sound.id]
        @widgets.add [type: 'HotspotWidget', sound_id: sound.id]
        @widgets.add [type: 'HotspotWidget', sound_id: sound.id]
        @widgets.add [type: 'HotspotWidget']
        @widgets.add [type: 'SpriteWidget']

        @widgets.soundRemoved(sound)
        expect(@widgets.length).toEqual 2
        expect(@widgets.where(sound_id: sound.id).length).toEqual 0


    describe 'remove video', ->
      it 'removes all the corresponding hotspots with that video', ->
        video = new App.Models.Video id: 3
        @widgets.add [type: 'HotspotWidget', video_id: video.id]
        @widgets.add [type: 'HotspotWidget', video_id: video.id]
        @widgets.add [type: 'HotspotWidget', video_id: video.id]
        @widgets.add [type: 'HotspotWidget']
        @widgets.add [type: 'SpriteWidget']

        @widgets.videoRemoved(video)
        expect(@widgets.length).toEqual 2
        expect(@widgets.where(video_id: video.id).length).toEqual 0


    describe 'remove font', ->
      beforeEach ->
        @font = new App.Models.Font id: 1
        anotherId = 2
        @storybook = new App.Models.Storybook
        @widgets.keyframe = new App.Models.Keyframe
          scene: new App.Models.Scene(storybook: @storybook)
        @widgets.add [type: 'TextWidget', font_id: @font.id]
        @widgets.add [type: 'TextWidget', font_id: @font.id]
        @widgets.add [type: 'TextWidget', font_id: @font.id]
        @widgets.add [type: 'TextWidget', font_id: anotherId]
        @widgets.add [type: 'SpriteWidget']

      it 'sets remove text widgets with that font, if no default font exists', ->
        @widgets.fontRemoved(@font)
        expect(@widgets.length).toEqual 2
        expect(@widgets.where(font_id: @font.id).length).toEqual 0

      it 'sets the font to default for all text widgets with the deleted font', ->
        sinon.stub(@storybook, 'defaultFont').returns(new App.Models.Font(id: 4000))
        @widgets.fontRemoved(@font)
        expect(@widgets.length).toEqual 5
        expect(@widgets.where(font_id: 4000).length).toEqual 3


