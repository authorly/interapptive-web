describe "App.Collections.CurrentWidgetsCollection", ->
  it 'should be sorted correctly: first SpriteWidgets sorted by z_order, then Hotspots sorted by their id', ->
    widgets = new App.Collections.CurrentWidgets([
      new App.Models.SpriteWidget(name: 'sprite_1', z_order: 3),
      new App.Models.ButtonWidget(name: 'sprite_2', z_order: 1),
      new App.Models.HotspotWidget(name: 'hotspot_1', id: 2001),
      new App.Models.HotspotWidget(name: 'hotspot_2', id: 2000),
    ])
    expect(widgets.map (w) -> w.get('name')).toEqual ['sprite_2', 'sprite_1', 'hotspot_2', 'hotspot_1']
