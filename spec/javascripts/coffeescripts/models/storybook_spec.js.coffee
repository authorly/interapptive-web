describe "App.Models.Storybook", ->

  beforeEach ->
    @server = sinon.fakeServer.create()

    @storybook = new App.Models.Storybook

  afterEach ->
    @server.restore()

  describe 'remove an image', ->
    beforeEach ->
      @image = new App.Models.Image(id: 1)
      @storybook.images = new App.Collections.ImagesCollection [@image], storybook: @storybook
      @scene = new App.Models.Scene
        storybook: @storybook
      @storybook.scenes.add @scene

    it 'removes all corresponding sprites', ->
      sprite = new App.Models.SpriteWidget
        image_id: @image.id
      @scene.widgets.add sprite
      expect(@scene.widgets.length).toEqual 1

      @storybook.images.remove @image

      expect(@scene.widgets.length).toEqual 0

    it 'does not remove buttons, but sets the image_id to null', ->
      sprite = new App.Models.ButtonWidget
        image_id: @image.id
      @scene.widgets.add sprite
      expect(@scene.widgets.length).toEqual 1

      @storybook.images.remove @image

      expect(@scene.widgets.length).toEqual 1
      expect(@scene.widgets.at(0).get('image_id')).toEqual null

    it 'but sets the selected_image_id to null', ->
      sprite = new App.Models.ButtonWidget
        selected_image_id: @image.id
      @scene.widgets.add sprite
      expect(@scene.widgets.length).toEqual 1

      @storybook.images.remove @image

      expect(@scene.widgets.length).toEqual 1
      expect(@scene.widgets.at(0).get('selected_image_id')).toEqual null


  describe 'as json', ->
    it 'does not send preview_image_url', ->
      @storybook.set preview_image_url: ''
      expect(@storybook.toJSON().preview_image_url).toBeUndefined()


  describe 'voiceoverNeeded', ->
    beforeEach ->
      @scene = new App.Models.Scene
        storybook: @storybook
        is_main_menu: true
      @storybook.scenes.add @scene
      @rtm = new App.Models.ButtonWidget
        name: 'read_to_me'
        disabled: false
      @scene.widgets.add(@rtm)
      @auto = new App.Models.ButtonWidget
        name: 'auto_play'
        disabled: false
      @scene.widgets.add(@auto)


    it 'should be true for enabled read to me and enabled auto play ', ->
      expect(@storybook.voiceoverNeeded()).toBeTruthy()


    it 'should be true for enabled read to me and disabled auto play ', ->
      @auto.set(disabled: true)

      expect(@storybook.voiceoverNeeded()).toBeTruthy()


    it 'should be true for disabled read to me and enabled auto play ', ->
      @rtm.set(disabled: true)

      expect(@storybook.voiceoverNeeded()).toBeTruthy()


    it 'should be false for disabled read to me and disabled auto play ', ->
      @rtm.set(disabled: true)
      @auto.set(disabled: true)

      expect(@storybook.voiceoverNeeded()).toBeFalsy()
