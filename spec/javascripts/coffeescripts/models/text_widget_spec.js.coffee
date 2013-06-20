describe "App.Models.TextWidget", ->

  it 'has the right defaults', ->
    @widget = new App.Models.TextWidget
    expect(@widget.get('type')).toEqual 'TextWidget'
    expect(@widget.get('string')).toEqual 'Double click to edit or drag to move'
    expect(@widget.get('z_order')).toEqual 6000
    expect(@widget.get('position')).toEqual { x : 512, y : 384 }

  describe 'wordcount', ->
    beforeEach ->
      @widget = new App.Models.TextWidget

    it 'is 0 if empty', ->
      @widget.set string: ''
      expect(@widget.wordCount()).toEqual 0

    it 'is 0 if whitespace', ->
      @widget.set string: "  \n  "
      expect(@widget.wordCount()).toEqual 0

    it 'is the number of words', ->
      @widget.set string: 'one two three'
      expect(@widget.wordCount()).toEqual 3

    it 'ignores whitespace at the end', ->
      @widget.set string: 'one  '
      expect(@widget.wordCount()).toEqual 1

    it 'ignores whitespace in front', ->
      @widget.set string: '  one'
      expect(@widget.wordCount()).toEqual 1

    it 'ignores whitespace in the middle front', ->
      @widget.set string: 'one  two'
      expect(@widget.wordCount()).toEqual 2

    it 'does not split on punctuation', ->
      @widget.set string: "the string's word count is almost-ready; we're happy"
      expect(@widget.wordCount()).toEqual 8
