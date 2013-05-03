describe "App.Models.HotspotWidget", ->

  it 'has the right defaults', ->
    @widget = new App.Models.HotspotWidget
    expect(@widget.get('type')).toEqual 'HotspotWidget'
    expect(@widget.get('z_order')).toEqual 5000
    expect(@widget.get('radius')).toEqual 48
    expect(@widget.get('position')).toEqual { x : 512, y : 384 }

