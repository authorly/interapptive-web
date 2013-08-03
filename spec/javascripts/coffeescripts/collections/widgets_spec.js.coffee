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


