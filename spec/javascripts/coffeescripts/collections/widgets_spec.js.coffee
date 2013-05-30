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
