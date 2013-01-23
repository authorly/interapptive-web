describe "App.Collections.KeyframesCollection", ->

  it "should be defined", ->
    expect(App.Collections.KeyframesCollection).toBeDefined()

  it "can be instantiated", ->
    keyframesCollection = new App.Collections.KeyframesCollection([], {scene_id: 1})
    expect(keyframesCollection).not.toBeNull()

  # TODO: WA: Following tests should be enabled only when
  # App.Models.Scene#spriteWidgets() function is working
  #describe 'next available position', ->
    #beforeEach ->
      #@collection = new App.Collections.KeyframesCollection
      #sinon.stub(@collection, 'announceAnimation')
      #@keyframe = new App.Models.Keyframe

    #it 'should be null for an animationkeyframe', ->
      #@collection.add { position: 0 }
      #@keyframe.set is_animation: true
      #expect(@collection.nextPosition(@keyframe)).toEqual null

    #it 'should be 0 for the first keyframe', ->
      #expect(@collection.nextPosition(@keyframe)).toEqual 0

    #it 'should be the next number when there is no animation keyframe', ->
      #@collection.add { position: 0 }
      #@collection.add { position: 1 }
      #expect(@collection.nextPosition(@keyframe)).toEqual 2

    #it 'should be the next number when there is an animation keyframe', ->
      #@collection.add { position: 0 }
      #@collection.add { is_animation: true }
      #expect(@collection.nextPosition(@keyframe)).toEqual 1

  #describe 'recalculate positions', ->
    #describe 'on destroy', ->
      #beforeEach ->
        #@server = sinon.fakeServer.create()

        #storybook = new App.Models.Storybook(id: 1)
        #scene = new App.Models.Scene({ id: 1 }, { collection: storybook.scenes })

        #@collection = new App.Collections.KeyframesCollection [], scene: scene
        #sinon.stub(@collection, 'announceAnimation')
        #@collection.add { title: '0', position: 0 }
        #@collection.add { title: '1', position: 1 }
        #@collection.add { title: '2', position: 2 }
        #@collection.add { title: 'animation', is_animation: true }

      #afterEach ->
        #@server.restore()

      #it 'should recalculate positions correctly', ->

        #@collection.remove(@collection.at(2))
        #expect(@collection.at(0).get('position')).toEqual null
        #expect(@collection.at(1).get('position')).toEqual 0
        #expect(@collection.at(2).get('position')).toEqual 1
