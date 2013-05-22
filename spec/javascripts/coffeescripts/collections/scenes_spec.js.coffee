describe "App.Collections.ScenesCollection", ->

  describe 'next available position', ->
    beforeEach ->
      @storybook  = new App.Models.Storybook(id: 1)
      @scene      = new App.Models.Scene({ id: 1 }, { collection: @storybook.scenes })
      @collection = new App.Collections.ScenesCollection([], { storybook: @storybook })

    it 'should be null for a main menu scene', ->
      @collection.add { position: 0 }
      @scene.set is_main_menu: true
      expect(@collection.nextPosition(@scene)).toEqual null

    it 'should be 0 for the first scene', ->
      expect(@collection.nextPosition(@scene)).toEqual 0

    it 'should be the next number when there is no main menu scene', ->
      @collection.add { position: 0 }
      @collection.add { position: 1 }
      expect(@collection.nextPosition(@scene)).toEqual 2

    it 'should be the next number when there is an main menu scene', ->
      @collection.add { position: 0 }
      @collection.add { is_main_menu: true }
      expect(@collection.nextPosition(@scene)).toEqual 1
