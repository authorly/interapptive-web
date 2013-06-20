describe "App.Models.TextWidget", ->

  it 'has the right defaults', ->
    @widget = new App.Models.TextWidget
    expect(@widget.get('type')).toEqual 'TextWidget'
    expect(@widget.get('string')).toEqual 'Double click to edit or drag to move'
    expect(@widget.get('z_order')).toEqual 6000
    expect(@widget.get('position')).toEqual { x : 512, y : 384 }
