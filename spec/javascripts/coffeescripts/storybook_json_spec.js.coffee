describe "App.JSON", ->

  beforeEach ->
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()

  beforeEach ->
    @storybook = new App.Models.Storybook
      pageFlipTransitionDuration: 1
      paragraphTextFadeDuration: 2
      autoplayPageTurnDelay: 3
      autoplayParagraphDelay: 4

    @rim_selected_image = new App.Models.Image
      id:  1
      url: 'http://authorly.dev/read_it_myself-over.png'
    @storybook.images.add @rim_selected_image

    # storybooks come with a main menu scene
    @mainMenu = new App.Models.Scene {
      id: 2
      storybook: @storybook
      is_main_menu: true
      widgets: [
        {'type':'ButtonWidget', image_id: null,'id':1,'name':'read_it_myself', selected_image_id: @rim_selected_image.id},
        {'type':'ButtonWidget', image_id: null,'id':2,'name':'read_to_me'},
        {'type':'ButtonWidget', image_id: null,'id':3,'name':'auto_play'}
      ]
    }, parse: true
    @storybook.scenes.add @mainMenu

    @mainMenuKeyframe = new App.Models.Keyframe {
      id: 101,
      scene: @mainMenu,
      position: 0,
      widgets: [
        { 'type': 'SpriteOrientation', 'id': 4, keyframe_id: 101, sprite_widget_id: 1, position: { x: 200, y: 100}, scale: 1 }
        { 'type': 'SpriteOrientation', 'id': 5, keyframe_id: 101, sprite_widget_id: 2, position: { x: 200, y: 200}, scale: 1 }
        { 'type': 'SpriteOrientation', 'id': 6, keyframe_id: 101, sprite_widget_id: 3, position: { x: 200, y: 300}, scale: 1 }
      ]
    }, parse: true
    @mainMenu.keyframes.add @mainMenuKeyframe


  describe "configuration", ->
    beforeEach ->
      @json = new App.JSON(@storybook)
      @configuration = @json.app.Configurations

    it 'is generated correctly', ->
      expect(@configuration).toBeDefined()

    it 'has the necesasry settings', ->
      expect(@configuration.pageFlipTransitionDuration).toEqual 1
      expect(@configuration.paragraphTextFadeDuration).toEqual 2
      expect(@configuration.autoplayPageTurnDelay).toEqual 3
      expect(@configuration.autoplayParagraphDelay).toEqual 4


  describe "the main menu", ->
    beforeEach ->
      @json = new App.JSON(@storybook)

    it 'is generated correctly', ->
      expect(@json.app.MainMenu).toBeDefined()

      expect(@json.app.MainMenu.CCSprites.length).toEqual 0
      expect(@json.app.MainMenu.fallingPhysicsSettings).toBeDefined()
      # a fake entry as the IOS app needs something
      expect(@json.app.MainMenu.fallingPhysicsSettings.plistfilename).toEqual 'snowflake-main-menu.plist'

      items = @json.app.MainMenu.MenuItems
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
      expect(item.tappedStateImage).toEqual '/assets/sprites/read_to_me.png'
      expect(item.position).toEqual [200, 200]
      expect(item.storyMode).toEqual 'readToMe'

      # autoplay
      item = items[2]
      expect(item.normalStateImage).toEqual '/assets/sprites/auto_play.png'
      expect(item.tappedStateImage).toEqual '/assets/sprites/auto_play.png'
      expect(item.position).toEqual [200, 300]
      expect(item.storyMode).toEqual 'autoPlay'

    # it 'is updated if its entries change', ->
      # @storybook.scenes.at(0).widgets.at(0).set
        # position:
          # x: 150
          # y: 120
      # items = @json.app.MainMenu.MenuItems
      # item = items[0]
      # expect(item.position).toEqual [150, 120]

  describe "scenes", ->

    beforeEach ->
      @sprite_image = new App.Models.Image
        id:  10
        url: 'https://interapptive.s3.amazonaws.com/images/4/avatar3.jpg'
      @storybook.images.add @sprite_image

      @scene1 = new App.Models.Scene {
        id: 3
        position: 0
        storybook: @storybook
        font_color: {r: 232, g: 148, b: 175 }
        font_size: "36"
        font_face: "Verdana"
        # TODO XXX why do we have the full path in the sound_id and video_id attributes?
        widgets: [
          { 'type': 'HotspotWidget', 'id': 7, 'position': {'x': 510, 'y': 310}, 'radius': 60, 'sound_id': "https://interapptive.s3.amazonaws.com/sounds/6/voicemail_received.wav"
          },
          { 'type': 'HotspotWidget', 'id': 8, 'position': {'x': 410, 'y': 210}, 'radius': 20, 'video_id': "https://interapptive.s3.amazonaws.com/videos/8/voicemail_received.mov"
          },
          { 'type': 'SpriteWidget', 'id': 9, 'image_id': @sprite_image.id},
        ]
      }, parse: true

      @keyframe1 = new App.Models.Keyframe {
        id: 1,
        scene: @scene1,
        position: 1,
        animation_duration: 2.7,
        widgets: [
          { 'type': 'SpriteOrientation', 'id': 11, keyframe_id: 1, sprite_widget_id: 9, position: { x: 400, y: 200}, scale: 1.5 }
          { 'type': 'TextWidget', 'id': 12, 'position': {'x': 120, 'y': 330}, 'string': 'Some text' },
          { 'type': 'TextWidget', 'id': 13, 'position': {'x': 150, 'y': 370}, 'string': 'Some other text' },
        ],
        content_highlight_times: [1, 2, 4, 5, 20]
        url: 'https://interapptive.s3.amazonaws.com/sounds/29/page2.mp3'
      }, parse: true
      @scene1.keyframes.add @keyframe1

      # with no text
      @keyframe2 = new App.Models.Keyframe {
        id: 2,
        scene: @scene1,
        position: 2,
        widgets: [
          { 'type': 'SpriteOrientation', 'id': 14, keyframe_id: 2, sprite_widget_id: 9, position: { x: 500, y: 300}, scale: 1 }
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

      expect(api.CCStoryTouchableNode).toBeDefined()
      expect(api.CCStoryTouchableNode.nodes).toBeDefined()
      hotspots = api.CCStoryTouchableNode.nodes
      expect(hotspots.length).toEqual 2

      hotspot = hotspots[0]
      expect(hotspot.radius).toEqual 60
      expect(hotspot.position).toEqual [510, 310]
      expect(hotspot.soundToPlay).toEqual "https://interapptive.s3.amazonaws.com/sounds/6/voicemail_received.wav"
      expect(hotspot.videoToPlay).toBeUndefined()

      hotspot = hotspots[1]
      expect(hotspot.soundToPlay).toBeUndefined()
      expect(hotspot.videoToPlay).toEqual "https://interapptive.s3.amazonaws.com/videos/8/voicemail_received.mov"

      keyframes = page.text.paragraphs
      expect(keyframes).toBeDefined()
      expect(keyframes.length).toEqual(2)

      keyframe = keyframes[0]
      # TODO setup these according to how the app works; add docs
      # expect(keyframe.voiceAudioFile).toEqual 'https://interapptive.s3.amazonaws.com/sounds/9/scene_1_keyframe_1_voiceover.mov'
      # expect(keyframe.highlightingTimes).toEqual [0.1, 3.3, 7.5]
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
      expect(keyframe.voiceAudioFile).toEqual 'https://interapptive.s3.amazonaws.com/sounds/29/page2.mp3'

      keyframe = keyframes[1]
      # one fake entry
      expect(keyframe.linesOfText.length).toEqual(1)
      expect(keyframe.voiceAudioFile).toBeUndefined()
      # with a default `0` value, so the iphone app does not crash
      expect(keyframe.highlightingTimes).toEqual [0]
      text = keyframe.linesOfText[0]
      expect(text.text).toEqual ''

      sprites = api.CCSprites
      expect(sprites).toBeDefined()
      expect(sprites.length).toEqual 1

      sprite = sprites[0]
      expect(sprite.image).toEqual "https://interapptive.s3.amazonaws.com/images/4/avatar3.jpg"
      expect(sprite.spriteTag).toEqual 1
      expect(sprite.position).toEqual [400, 200]

      expect(api.CCMoveTo).toBeDefined()
      expect(api.CCMoveTo.length).toEqual 2
      move = api.CCMoveTo[0]
      expect(move.position).toEqual [400, 200]
      expect(move.duration).toEqual 3
      k1MoveId = move.actionTag

      move = api.CCMoveTo[1]
      expect(move.position).toEqual [500, 300]
      expect(move.duration).toEqual 3
      k2MoveId = move.actionTag

      expect(api.CCScaleTo).toBeDefined()
      expect(api.CCScaleTo.length).toEqual 2
      scale = api.CCScaleTo[0]
      expect(scale.intensity).toEqual 1.5
      expect(scale.duration).toEqual 3
      k1ScaleId = scale.actionTag

      scale = api.CCScaleTo[1]
      expect(scale.intensity).toEqual 1
      expect(scale.duration).toEqual 3
      k2ScaleId = scale.actionTag

      expect(api.CCStorySwipeEnded).toBeDefined()
      actions = api.CCStorySwipeEnded.runAction
      expect(actions).toBeDefined()


      # scale & position for the first keyframe
      action = actions[0]
      expect(action).toBeDefined()
      expect(action.runAfterSwipeNumber).toEqual 0
      expect(action.spriteTag).toEqual 1
      expect(action.actionTags).toEqual [ k1ScaleId, k1MoveId ]

      # scale & position for the second keyframe
      action = actions[1]
      expect(action).toBeDefined()
      expect(action.runAfterSwipeNumber).toEqual 1
      expect(action.spriteTag).toEqual 1
      expect(action.actionTags).toEqual [ k2ScaleId, k2MoveId ]


    # it 'addition', ->
      # @scene2 = new App.Models.Scene {
        # id: 4
        # storybook: @storybook
        # font_color: [r:0, g:0, b:0]
      # }, parse: true
      # @storybook.scenes.add @scene2

      # expect(@json.app.Pages).toBeDefined()
      # expect(@json.app.Pages.length).toEqual 2


    # it 'removal', ->
      # @storybook.scenes.remove @storybook.scenes.at(1)
      # expect(@json.app.Pages.length).toEqual 0


    # describe 'change', ->
      # it 'is updated when attributes change', ->
        # # the following attributes can change: sound_id, sound_repeat_count, position,
        # # font_face, font_size, font_color
        # @scene1.set
          # position: 3
          # font_face: 'Arial'
          # font_color: {r: 255, g: 0, b: 120 }
          # font_size: '48'

        # settings = @json.app.Pages[0].Page.settings
        # expect(settings.number).toEqual 3
        # expect(settings.fontType).toEqual "Arial"
        # expect(settings.fontColor).toEqual [255, 0, 120]
        # expect(settings.fontSize).toEqual 48

    # describe 'change hotspots', ->

      # it 'is updated if a hotspot changes', ->
        # @storybook.scenes.at(1).widgets.at(0).set
          # position:
            # x: 150
            # y: 120
        # hotspot = @json.app.Pages[0].API.CCStoryTouchableNode.nodes[0]
        # expect(hotspot.position).toEqual [150, 120]

      # it 'is updated if a hotspot is removed', ->
        # widgets = @storybook.scenes.at(1).widgets
        # widgets.remove widgets.at(0)
        # expect(@json.app.Pages[0].API.CCStoryTouchableNode.nodes.length).toEqual(1)

    # describe 'keyframes', ->
       # describe 'addition', ->
       # describe 'removal', ->
       # describe 'change', ->


