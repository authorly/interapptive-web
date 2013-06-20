describe "App.Lib.StringHelper", ->

  describe 'wordcount', ->
    it 'is 0 if empty', ->
      expect(App.Lib.StringHelper.wordCount('')).toEqual 0

    it 'is 0 if whitespace', ->
      expect(App.Lib.StringHelper.wordCount("  \n  ")).toEqual 0

    it 'is the number of words', ->
      expect(App.Lib.StringHelper.wordCount('one two three')).toEqual 3

    it 'ignores whitespace at the end', ->
      expect(App.Lib.StringHelper.wordCount('one ')).toEqual 1

    it 'ignores whitespace in front', ->
      expect(App.Lib.StringHelper.wordCount(' one')).toEqual 1

    it 'ignores whitespace in the middle front', ->
      expect(App.Lib.StringHelper.wordCount('one  two')).toEqual 2

    it 'does not split on punctuation', ->
      expect(App.Lib.StringHelper.wordCount("the string's word count is almost-ready; we're happy")).toEqual 8
