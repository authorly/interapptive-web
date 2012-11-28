describe "App.Collections.ScenesCollection", ->

  it "should be defined", ->
    expect(App.Collections.ScenesCollection).toBeDefined();


  it "can be instantiated", ->
    scenesCollection = new App.Collections.ScenesCollection([], {storybook_id: 1})
    expect(scenesCollection).not.toBeNull()


  describe 'next available position', ->
    beforeEach ->
      @collection = new App.Collections.ScenesCollection
      @scene = new App.Models.Scene

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

