describe "App.JSON", ->

  beforeEach ->
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  beforeEach ->
    @storybook = new App.Models.Storybook {
      pageFlipTransitionDuration: 1
      paragraphTextFadeDuration: 2
      autoplayPageTurnDelay: 3
      autoplayKeyframeDelay: 4
      widgets: [
        {'type':'ButtonWidget', image_id: null,'id':40,'name':'home', position: {x: 200, y: 400}, scale: 1},
      ]
    }

    @rim_selected_image = new App.Models.Image
      id:  1
      url: 'http://authorly.dev/read_it_myself-over.png'
    @storybook.images.add @rim_selected_image

    @main_menu_image = new App.Models.Image
      id:  5
      url: 'http://authorly.dev/main-menu-image.png'
    @storybook.images.add @main_menu_image


    # storybooks come with a main menu scene
    @mainMenu = new App.Models.Scene {
      id: 2
      storybook: @storybook
      is_main_menu: true
      widgets: [
        {'type':'ButtonWidget', image_id: null,'id':1,'name':'read_it_myself', selected_image_id: @rim_selected_image.id, position: {x: 200, y: 100}, scale: 1},
        {'type':'ButtonWidget', image_id: null,'id':2,'name':'read_to_me', position: {x: 200, y: 200}, scale: 1},
        {'type':'ButtonWidget', image_id: null,'id':3,'name':'auto_play', position: {x: 200, y: 300}, scale: 1},
        {'type':'SpriteWidget', image_id: @main_menu_image.id,'id':4 }
      ]
    }, parse: true
    @storybook.scenes.add @mainMenu

    @mainMenuKeyframe = new App.Models.Keyframe {
      id: 101,
      scene: @mainMenu,
      position: null,
      widgets: [
        {type: 'SpriteOrientation', sprite_widget_id: 4, position: {x:200, y:10}, scale: 1.2}
      ]
    }, parse: true
    @mainMenu.keyframes.add @mainMenuKeyframe


  describe "configuration", ->
    beforeEach ->
      @json = new App.JSON(@storybook)
      @configuration = @json.app.Configurations

    it 'is generated correctly', ->
      expect(@configuration).toBeDefined()

    it 'has the necessary settings', ->
      expect(@configuration.pageFlipTransitionDuration).toEqual 1
      expect(@configuration.paragraphTextFadeDuration).toEqual 2
      expect(@configuration.autoplayPageTurnDelay).toEqual 3
      expect(@configuration.autoplayKeyframeDelay).toEqual 4

    it 'has the home menu', ->
      menu = @configuration.homeMenuForPages
      expect(menu).toBeDefined()
      expect(menu.position).toEqual [200, 400]
      expect(menu.normalStateImage).toEqual '/assets/sprites/home.png'
      expect(menu.tappedStateImage).toEqual '/assets/sprites/home-over.png'


  describe "the main menu", ->
    beforeEach ->
      @json = new App.JSON(@storybook)

    it 'is generated correctly', ->
      menu = @json.app.MainMenu
      expect(menu).toBeDefined()

      sprites = menu.CCSprites
      expect(sprites.length).toEqual 1
      sprite = sprites[0]
      expect(sprite.spriteTag).toEqual 1
      expect(sprite.image).toEqual @main_menu_image.get('url')
      expect(sprite.position).toEqual [200, 10]
      expect(sprite.scale).toEqual 1.2
      expect(sprite.visible).toEqual true

      expect(menu.fallingPhysicsSettings).toBeDefined()
      # a fake entry as the IOS app needs something
      expect(menu.fallingPhysicsSettings.plistfilename).toEqual 'snowflake-main-menu.plist'

      items = menu.MenuItems
      expect(items.length).toEqual 3

      # read it myself
      item = items[0]
      expect(item.normalStateImage).toEqual '/assets/sprites/read_it_myself.png'
      expect(item.tappedStateImage).toEqual 'http://authorly.dev/read_it_myself-over.png'
      expect(item.position).toEqual [200, 100]
      expect(item.storyMode).toEqual 'readItMyself'

      # read to me
      item = items[1]
      expect(item.normalStateImage).toEqual '/assets/sprites/read_to_me.png'
      expect(item.tappedStateImage).toEqual '/assets/sprites/read_to_me-over.png'
      expect(item.position).toEqual [200, 200]
      expect(item.storyMode).toEqual 'readToMe'

      # autoplay
      item = items[2]
      expect(item.normalStateImage).toEqual '/assets/sprites/auto_play.png'
      expect(item.tappedStateImage).toEqual '/assets/sprites/auto_play-over.png'
      expect(item.position).toEqual [200, 300]
      expect(item.storyMode).toEqual 'autoPlay'


  describe "scenes", ->

    beforeEach ->
      @sprite_image = new App.Models.Image
        id:  10
        url: 'https://interapptive.s3.amazonaws.com/images/4/avatar3.jpg'
      @storybook.images.add @sprite_image

      @sound = new App.Models.Sound
        id: 11
        url: "https://interapptive.s3.amazonaws.com/sounds/11/voicemail_received.wav"
      @storybook.sounds.add @sound

      @video = new App.Models.Video
        id: 12
        url: "https://interapptive.s3.amazonaws.com/videos/12/voicemail_received.mov"
      @storybook.videos.add @video

      @custom_font = new App.Models.Font
        id: 13
        url: 'https://interapptive.s3.amazonaws.com/fonts/13/Russo_One.ttf'
        asset_type: 'custom'
      @storybook.fonts.add @custom_font

      @system_font = new App.Models.Font
        id: 14
        url: 'Arial.ttf'
        asset_type: 'system'
      @storybook.fonts.add @system_font

      @scene1 = new App.Models.Scene {
        id: 3
        position: 0
        storybook: @storybook
        font_color: {r: 232, g: 148, b: 175 }
        font_size: "36"
        font_face: "Verdana"
        widgets: [
          { 'type': 'SpriteWidget', 'id': 9, 'image_id': @sprite_image.id},
        ]
      }, parse: true

      @keyframe1 = new App.Models.Keyframe {
        id: 1,
        scene: @scene1,
        position: 0,
        animation_duration: 3,
        widgets: [
          { 'type': 'SpriteOrientation', 'id': 11, keyframe_id: 1, sprite_widget_id: 9, position: { x: 400, y: 200}, scale: 1.5 }
          { 'type': 'TextWidget', 'id': 12, 'font_id': 13, 'position': {'x': 120, 'y': 330}, 'string': 'Some text' },
          { 'type': 'TextWidget', 'id': 13, 'font_id': 14, 'position': {'x': 150, 'y': 370}, 'string': 'Some other text' },
          { 'type': 'HotspotWidget', 'id': 7, 'position': {'x': 510, 'y': 310}, 'radius': 60, 'sound_id': @sound.id },
        ],
        content_highlight_times: [1, 2, 4, 5, 20]
        voiceover_id: 11
      }, parse: true
      @scene1.keyframes.add @keyframe1

      # with no text
      @keyframe2 = new App.Models.Keyframe {
        id: 2,
        scene: @scene1,
        position: 1,
        animation_duration: 2.7,
        widgets: [
          { 'type': 'SpriteOrientation', 'id': 14, keyframe_id: 2, sprite_widget_id: 9, position: { x: 500, y: 300}, scale: 1 },
          { 'type': 'HotspotWidget', 'id': 8, 'position': {'x': 410, 'y': 210}, 'radius': 20, 'video_id': @video.id }
        ]
      }, parse: true
      @scene1.keyframes.add @keyframe2

      @storybook.scenes.add @scene1
      @json = new App.JSON(@storybook)


    it 'are generated correctly', ->
      expect(@json.app.Pages).toBeDefined()
      expect(@json.app.Pages.length).toEqual 1

      page_node = @json.app.Pages[0]

      page = page_node.Page
      expect(page.settings).toBeDefined()
      settings = page.settings
      expect(settings.number).toEqual 1

      api = page_node.API
      expect(api).toBeDefined()

      keyframes = page.text.paragraphs
      expect(keyframes).toBeDefined()
      expect(keyframes.length).toEqual(2)

      keyframe = keyframes[0]
      expect(keyframe.linesOfText.length).toEqual(2)

      text = keyframe.linesOfText[0]
      expect(text.text).toEqual 'Some text'
      expect(text.xOffset).toEqual 120
      expect(text.yOffset).toEqual 330

      text = keyframe.linesOfText[1]
      expect(text.text).toEqual 'Some other text'
      expect(text.xOffset).toEqual 150
      expect(text.yOffset).toEqual 370

      expect(keyframe.highlightingTimes).toEqual [1, 2, 4, 5, 20]
      expect(keyframe.voiceAudioFile).toEqual "https://interapptive.s3.amazonaws.com/sounds/11/voicemail_received.wav"

      hotspots = keyframe.hotspots
      expect(hotspots.length).toEqual 1

      hotspot = hotspots[0]
      expect(hotspot.radius).toEqual 60
      expect(hotspot.position).toEqual [510, 310]
      expect(hotspot.soundToPlay).toEqual @sound.get('url')
      expect(hotspot.videoToPlay).toBeUndefined()


      keyframe = keyframes[1]
      # one fake entry
      expect(keyframe.linesOfText.length).toEqual(1)
      expect(keyframe.voiceAudioFile).toBeUndefined()
      # with a default `0` value, so the iphone app does not crash
      expect(keyframe.highlightingTimes).toEqual [0]

      text = keyframe.linesOfText[0]
      expect(text.text).toEqual ''

      hotspots = keyframe.hotspots
      expect(hotspots.length).toEqual 1
      hotspot = hotspots[0]
      expect(hotspot.soundToPlay).toBeUndefined()
      expect(hotspot.videoToPlay).toEqual @video.get('url')

      sprites = api.CCSprites
      expect(sprites).toBeDefined()
      expect(sprites.length).toEqual 1
      console.log sprites

      sprite = sprites[0]
      expect(sprite.image).toEqual "https://interapptive.s3.amazonaws.com/images/4/avatar3.jpg"
      expect(sprite.spriteTag).toEqual 2
      expect(sprite.position).toEqual [400, 200]

      expect(api.CCMoveTo).toBeDefined()
      expect(api.CCMoveTo.length).toEqual 2
      move = api.CCMoveTo[0]
      expect(move.position).toEqual [400, 200]
      expect(move.duration).toEqual 0
      k1MoveId = move.actionTag

      move = api.CCMoveTo[1]
      expect(move.position).toEqual [500, 300]
      expect(move.duration).toEqual 2.7
      k2MoveId = move.actionTag

      expect(api.CCScaleTo).toBeDefined()
      expect(api.CCScaleTo.length).toEqual 2
      scale = api.CCScaleTo[0]
      expect(scale.intensity).toEqual 1.5
      expect(scale.duration).toEqual 0
      k1ScaleId = scale.actionTag

      scale = api.CCScaleTo[1]
      expect(scale.intensity).toEqual 1
      expect(scale.duration).toEqual 2.7
      k2ScaleId = scale.actionTag

      expect(api.CCStorySwipeEnded).toBeDefined()
      actions = api.CCStorySwipeEnded.runAction
      expect(actions).toBeDefined()


      # scale & position for the first keyframe - not needed
      # action = actions[0]
      # expect(action).toBeDefined()
      # expect(action.runAfterSwipeNumber).toEqual 0
      # expect(action.spriteTag).toEqual 1
      # expect(action.actionTags).toEqual [ k1ScaleId, k1MoveId ]

      # scale & position for the second keyframe
      action = actions[0]
      expect(action).toBeDefined()
      expect(action.runAfterSwipeNumber).toEqual 1
      expect(action.spriteTag).toEqual 2
      expect(action.actionTags).toEqual [ k2ScaleId, k2MoveId ]

