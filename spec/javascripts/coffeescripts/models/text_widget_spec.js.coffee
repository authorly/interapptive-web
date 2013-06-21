describe "App.Models.TextWidget", ->

  it 'has the right defaults', ->
    @widget = new App.Models.TextWidget
    expect(@widget.get('type')).toEqual 'TextWidget'
    expect(@widget.get('string')).toEqual 'Double click to edit or drag to move'
    expect(@widget.get('z_order')).toEqual 6000
    expect(@widget.get('position')).toEqual { x : 512, y : 384 }

  describe 'font', ->
    beforeEach ->
      @storybook = new App.Models.Storybook
      @keyframe = new App.Models.Keyframe
        scene: new App.Models.Scene(storybook: @storybook)

    it 'gets the default font of the storybook, if there is no font', ->
      sinon.stub(@storybook, 'defaultFont').returns(new App.Models.Font(id: 13))
      widget = new App.Models.TextWidget({}, collection: @keyframe.widgets)

      expect(widget.get('font_id')).toEqual 13

    it 'keeps its font id, if set', ->
      widget = new App.Models.TextWidget({font_id: 2}, collection: @keyframe.widgets)

      expect(widget.get('font_id')).toEqual 2
