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

  describe 'z_order validation', ->

    it 'does not allow button widgets before sprite widgets', ->
      order =
        1: new App.Models.ButtonWidget
        2: new App.Models.SpriteWidget
      expect(@widgets.validZOrder(order)).toEqual false


    it 'allows a bunch of sprite widgets, followed by a bunch of button widgets', ->
      order =
        1: new App.Models.SpriteWidget
        2: new App.Models.SpriteWidget
        3: new App.Models.SpriteWidget
        4: new App.Models.ButtonWidget
        5: new App.Models.ButtonWidget

      expect(@widgets.validZOrder(order)).toEqual true


    it 'allows a bunch of sprite widgets', ->
      order =
        1: new App.Models.SpriteWidget
        2: new App.Models.SpriteWidget

      expect(@widgets.validZOrder(order)).toEqual true


    it 'allows a bunch of button widgets', ->
      order =
        1: new App.Models.ButtonWidget
        2: new App.Models.ButtonWidget

      expect(@widgets.validZOrder(order)).toEqual true
