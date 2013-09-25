describe "App.Models.SpriteWidget", ->

  it 'has the right defaults', ->
    @widget = new App.Models.SpriteWidget
    expect(@widget.get('type')).toEqual 'SpriteWidget'

  describe 'parsing', ->
    beforeEach ->
      @widget = new App.Models.SpriteWidget({
        id: 13
        image_id: 1
        position: {x: 2, y: 3}
        scale: { horizontal: 170, vertical: 300 }
      }, parse: true)

    it 'stores the id', ->
      expect(@widget.id).toEqual 13

    it 'stores the image_id attribute', ->
      expect(@widget.get('image_id')).toEqual 1

    it 'stores the position in a local variable, not in the attributes', ->
      expect(@widget.get('position')).toBeUndefined()
      expect(@widget.position).toEqual {x: 2, y: 3}

    it 'stores the scale in a local variable, not in the attributes', ->
      expect(@widget.get('scale')).toBeUndefined()
      expect(@widget.scale).toEqual { horizontal: 170, vertical: 300 }

