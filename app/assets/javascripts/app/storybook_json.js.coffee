##
#  This class is responsible for providing a structured JSON object
#  to the Simulator as well as the Authorly mobile software.
#
#  Most work is done by listening for various Backbone collections'
#  events and modifying the JSON object accordingly.
#
#  Pointers are used for tracking nodes by associated scene (scene._page)
#
# It doesn't have any CRUD stuff related to widgets.
# But it has CRUD support for scenes/keyframes and will add sprites to each
# scene, but not update/remove.
# Hotspots and text widgets are non-existant in the new implementation
class App.JSON

  constructor: (storybook) ->
    @spriteIdCounter = new App.Lib.Counter
    @actionIdCounter = new App.Lib.Counter

    @app =
      Configurations : @configurationNode(storybook)

    @storybook = storybook

    @initializeScenes()
    @resetScenes()

    @app


  initializeScenes: ->
    @scenes = @storybook.scenes
    # a hash mapping scene id's to the corresponding JSON fragment
    # so we don't pollute the scene object itself and still keep the reference
    # @scenesToJSON = {}

    # These listeners are never released; but they are initialized once
    # per app load; so we don't worry about memory leaks.
    # @scenes.on 'add',    @addSceneNode,    @
    # @scenes.on 'remove', @removeSceneNode, @


  resetScenes: ->
    @app.Pages = []
    # @scenesToJSON = {}

    @scenes.each (scene) =>
      if scene.isMainMenu()
        @app.MainMenu = @mainMenuNode(scene)
      else
        @addSceneNode(scene)


  # resetKeyframes: (collection) ->
    # page = collection.scene._page
    # page.Page.text.paragraphs = [] if page?

    # collection.each (keyframe) =>
      # @createParagraphNodeFrom(keyframe)


  # removeParagraphNodeFor: (keyframe) ->
    # page = keyframe.scene._page
    # throw new Error("Scene has no Page") unless page?
    # page.Page.text.paragraphs.splice(page.Page.text.paragraphs.indexOf(keyframe._paragraph), 1)


  addTextNodeFor: (keyframe, page) =>
    return if keyframe.isAnimation()

    widgets = keyframe.textWidgets()

    keyframeHighlightTimes = keyframe.get('content_highlight_times') || []
    if keyframeHighlightTimes.length < 1 then keyframeHighlightTimes.push(0)

    paragraph =
      # delayForPanning: true
      # highlightingTimes: [0.3, 1.3, #_.map(keyframe.get('content_highlight_times'), (num) -> Number(num))
      linesOfText: widgets.map (widget) ->
        color = widget.get('font_color')

        text: widget.get('string'),
        xOffset: Math.round(widget.get('position').x),
        yOffset: Math.round(widget.get('position').y),
        fontType: widget.fontFileName(),
        fontColor: [color.r, color.g, color.b],
        fontHighlightColor: [255, 0, 0],
        fontSize: Number(widget.get('font_size'))
      highlightingTimes: keyframeHighlightTimes
      voiceAudioFile: keyframe.get('url')

    if widgets.length == 0
      paragraph.linesOfText = [{
        text: '',
        xOffset: 0,
        yOffset: 0,
        fontType: 'Arial.ttf',
        fontColor: [255, 183, 213],
        fontHighlightColor: [255, 0, 0],
        fontSize: 25
      }]

    page.Page.text.paragraphs.push(paragraph)
    # keyframe._paragraph = paragraph
    #@createWidgetsFor(keyframe)


  addSceneNode: (scene) =>
    fontColor = scene.get('font_color')
    page =
      API:
        CCMoveTo:    []
        CCScaleTo:   []
        CCSequence:  []
        CCDelayTime: []
        CCSpawn:     []
        CCStorySwipeEnded:
          runAction: []
        CCStoryTouchableNode:
          nodes: scene.hotspotWidgets().map (widget) ->
            position = widget.get('position')
            hash =
              glitterIndicator: true
              stopEffectIndicator: false
              touchFlag: 1
              position: [Math.round(position.x), Math.round(position.y)]
              radius:   Math.round(widget.get('radius'))
            if (sound = widget.get('sound_id'))?
              hash.soundToPlay = sound
            if (video = widget.get('video_id'))?
              hash.videoToPlay = video

            hash
      Page:
        settings:
          number: scene.get('position') + 1
        text:
          paragraphs: []
    if scene.get('sound_url')?
      page.Page.settings.backgroundMusicFile =
        loop: scene.get('sound_repeat_count') == 0
        audioFilePath: scene.get('sound_url')
    # @scenesToJSON[scene.id] = page
    scene.keyframes.each (k) => @addTextNodeFor(k, page)

    # @addSceneListeners(scene)
    @app.Pages.push(page)

    # @createParagraphListenersFor(scene)

    @addSpriteNodesFor(scene, page)


  # addSceneListeners: (scene) ->
    # @scene.on 'change', @updateSceneNode, @


  # createParagraphListenersFor: (scene) ->
    # scene.keyframes.on 'add'   , @createParagraphNodeFrom , @
    # scene.keyframes.on 'remove', @removeParagraphNodeFor  , @
    # scene.keyframes.on 'reset' , @resetKeyframes          , @


  # removeSceneNode: (scene) ->
    # page = @scenesToJSON[scene.id]
    # throw new Error("Scene has no Page") unless page?

    # @app.Pages.splice(@app.Pages.indexOf(page), 1)
    # delete @scenesToJSON[scene.id]
    # # @_updatePageNumbers(page.Page.settings.number)


  addSpriteNodesFor: (scene, page) ->
    page.API.CCSprites ||= []

    _.each scene.spriteWidgets(), (spriteWidget) =>
      position = scene.keyframes.at(0).getOrientationFor(spriteWidget).get('position')
      spriteId = @spriteIdCounter.next()
      spriteNode =
        image:     spriteWidget.url()
        spriteTag: spriteId
        # TODO does the app require this? because we have a Move action for the first
        # keyframe anyway
        position:  [position.x, position.y]
      page.API.CCSprites.push(spriteNode)

      actions = page.API.CCStorySwipeEnded.runAction
      previousOrientation = null
      animationNode = null
      scene.keyframes.each (keyframe, index) =>
        orientation = keyframe.getOrientationFor(spriteWidget)
        keyframeIndex = keyframe.get('position')
        if keyframe.isAnimation() || keyframeIndex == 0 and index == 0
          duration = 0
        else
          duration = keyframe.get('animation_duration')

        # TODO optimization: reuse actions if they are available already
        scaleId = null
        unless previousOrientation? && previousOrientation.get('scale') == orientation.get('scale')
          scaleId = @actionIdCounter.next()
          page.API.CCScaleTo.push
            actionTag: scaleId
            duration: duration
            intensity: orientation.get('scale')

        moveId = null
        previousPosition = previousOrientation?.get('position')
        position = orientation.get('position')
        unless previousOrientation? && previousPosition.x == position.x && previousPosition.y == position.y
          moveId = @actionIdCounter.next()
          page.API.CCMoveTo.push
            actionTag: moveId
            duration: duration
            position: [Math.round(position.x), Math.round(position.y)]

        if keyframe.get('is_animation')
          delayId = @actionIdCounter.next()
          page.API.CCDelayTime.push
            actionTag: delayId
            duration: 3

          spawnId = @actionIdCounter.next()
          animationNode =
            actionTag: spawnId
            actions: []
          page.API.CCSpawn.push animationNode

          sequenceId = @actionIdCounter.next()
          page.API.CCSequence.push
            actionTag: sequenceId
            actions: [delayId, spawnId]

          spriteNode.actions = [sequenceId]
        else
          currentActions = _.without [scaleId, moveId], null
          if currentActions.length > 0
            if keyframeIndex == 0 and index == 0
              spriteNode.actions = currentActions

            else if keyframeIndex > 0
              actions.push
                runAfterSwipeNumber: index
                spriteTag: spriteId
                actionTags: currentActions
            # e
            else
              # keyframeIndex == 0 and index > 0 - there was an animation keyframe
              animationNode.actions = currentActions

          previousOrientation = orientation


  configurationNode: (storybook) ->
    home = storybook.widgets.at(0)
    homeButtonPosition = home.get('position')
    node =
      pageFlipSound:
        forward  : 'page-flip-sound.mp3'
        backward : 'page-flip-sound.mp3'
      pageFlipTransitionDuration: storybook.get('pageFlipTransitionDuration')
      paragraphTextFadeDuration:  storybook.get('paragraphTextFadeDuration')
      autoplayPageTurnDelay:      storybook.get('autoplayPageTurnDelay')
      autoplayKeyframeDelay:     storybook.get('autoplayKeyframeDelay')
      homeMenuForPages:
        normalStateImage : home.url()
        tappedStateImage : home.selectedUrl()
        position         : { x: homeButtonPosition.x, y: homeButtonPosition.y }

    node


  mainMenuNode: (scene) ->
    node =
      # audio:
        # backgroundMusic      : 'main-menu-title-sound.mp3'
        # backgroundMusicLoops : 1
        # soundEffect          : 'main-menu-title-sound.mp3'
        # soundEffectLoops     : 1

      CCSprites: []

      fallingPhysicsSettings:
        # draggable         : false
        # maxNumber         : 0
        # speedX            : 145
        # speedY            : 10
        # spinSpeed         : 10
        # slowDownSpeed     : 0.6
        # hasFloor          : false
        # hasWalls          : true
        # dropBetweenPoints : [0, 600]
        plistfilename     : 'snowflake-main-menu.plist'

      MenuItems:
        scene.buttonWidgets().map (button) ->
          position = button.get('position')
          str = App.Lib.StringHelper
          {
            normalStateImage: button.url()
            tappedStateImage: button.selectedUrl() || button.url()
            storyMode: str.decapitalize(str.camelize(button.get('name')))
            position: [Math.round(position.x), Math.round(position.y)]
          }

      API: {}

    _.each scene.spriteWidgets(), (spriteWidget) =>
      position = scene.keyframes.at(0).getOrientationFor(spriteWidget).get('position')
      spriteId = @spriteIdCounter.next()
      spriteNode =
        image:     spriteWidget.url()
        spriteTag: spriteId
        # TODO does the app require this? because we have a Move action for the first
        # keyframe anyway
        position:  [position.x, position.y]
        visible: true
      node.CCSprites.push(spriteNode)

    node



  # _updatePageNumbers: (from_number) =>
    # _.each(@app.Pages, (page) ->
      # if page.Page.settings.number > from_number
        # page.Page.settings.number = page.Page.settings.number - from_number
    # )


# The old implementation of the JSON generator, kept for reference
# nextSpriteTag = 1
# nextActionTag = 1
# nextTouchTag  = 1

# class App.StorybookJSON

  # constructor: ->

    # # The object that will become the JSON string
    # @document =
      # Configurations: @getconfigurationNode()

      # MainMenu:
        # audio:
          # backgroundMusic: 'main-menu-title-sound.mp3'
          # backgroundMusicLoops: 1
          # soundEffect: 'main-menu-title-sound.mp3'
          # soundEffectLoops: 1
        # CCSprites: [
          # {
            # image: 'background0000.jpg'
            # spriteTag: nextSpriteTag
            # visible: true
            # position: [512, 384]
          # }
        # ],
        # fallingPhysicsSettings:
          # draggable: false
          # maxNumber: 0
          # speedX: 145
          # speedY: 10
          # spinSpeed: 10
          # slowDownSpeed: 0.6
          # hasFloor: false
          # hasWalls: true
          # dropBetweenPoints: [0, 600]
          # plistfilename: 'snowflake-main-menu.plist'
        # MenuItems: [{
            # normalStateImage: "autoplay.png",
            # tappedStateImage: "autoplay-over.png",
            # storyMode: "autoPlay",
            # position: [100, 112]
        # }, {
            # normalStateImage: "read-it-myself.png",
            # tappedStateImage: "read-it-myself-over.png",
            # storyMode: "readItMyself",
            # position: [400, 112]
        # }, {
            # normalStateImage: "read-to-me.png",
            # tappedStateImage: "read-to-me-over.png",
            # storyMode: "readToMe",
            # position: [700, 112]
        # }],
        # API: {
            # CCFadeIn: [{
                # duration: 2,
                # actionTag: 22
            # }]
        # },
        # runActionsOnEnter: [{
            # spriteTag: nextSpriteTag,
            # actionTag: 22
        # }]

      # Pages: []

    # nextSpriteTag += 1
    # @document


  # @fromJSON: (json) ->
    # # TODO


  # toString: ->
    # JSON.stringify(@document)


  # resetPages: ->
    # @document.Pages = []


  # resetParagraphs: (scene) ->
    # page = scene._page
    # page.Page.text.paragraphs = [] if page?


  # # scene === page
  # createPage: (scene) ->

    # page =
      # API: {}
      # Page:
        # settings:
          # number: @document.Pages.length + 1,
          # fontType: "Arial",
          # fontColor: [0, 0, 0],
          # fontHighlightColor: [255, 0, 0],
          # fontSize: 24,
        # text:
          # paragraphs: []

    # if scene.get('sound_url')?
      # page.Page.settings.backgroundMusicFile =
        # loop: true
        # audioFilePath: scene.get('sound_url')

    # scene._page = page
    # # @createWidgetsFor(scene)
    # @createParagraphsFor(scene)
    # @document.Pages.push(page)
    # page

  # destroyPage: (scene) ->
    # page = scene._page
    # throw new Error("Scene has no Page") unless page?
    # @document.Pages.splice(@document.Pages.indexOf(page), 1)
    # @_updatePageNumbers(page.Page.settings.number)

  # _updatePageNumbers: (from_number) ->
    # _.each(@document.Pages, (page) ->
      # if page.Page.settings.number > from_number
        # page.Page.settings.number = page.Page.settings.number - from_number
    # )

  # createParagraphsFor: (scene) ->
    # scene.keyframes.each (keyframe) =>
      # @createParagraph(scene, keyframe)


  # # keyframe === paragraph
  # createParagraph: (scene, keyframe) ->
    # page = scene._page
    # throw new Error("Scene has no Page") unless page?
    # return false if keyframe.texts.length == 0

    # paragraph =
      # delayForPanning: true
      # highlightingTimes: _.map(keyframe.get('content_highlight_times'), (num) -> Number(num))
      # linesOfText: keyframe.texts.pluckContent()
      # voiceAudioFile: keyframe.get('url')

    # page.Page.text.paragraphs.push(paragraph)
    # keyframe._paragraph = paragraph
    # # @createWidgetsFor(keyframe)
    # paragraph

  # removeParagraph: (scene, keyframe) ->
    # page = scene._page
    # throw new Error("Scene has no Page") unless page?
    # page.Page.text.paragraphs.splice(page.Page.text.paragraphs.indexOf(keyframe._paragraph), 1)

  # updateParagraph: (keyframe) ->
    # keyframe._paragraph.highlightingTimes = _.map(keyframe.get('content_highlight_times'), (num) -> Number(num))
    # keyframe._paragraph.linesOfText       = keyframe.texts.pluckContent()
    # keyframe._paragraph.voiceAudioFile    = keyframe.get('url')

  # addText: (_text, keyframe) ->
    # keyframe ||= App.currentKeyframe()

    # p = keyframe._paragraph
    # throw new Error("Keyframe has no Paragraph") unless p?

    # _model = _text.model
    # _lineOfTextJSON =
      # text:    _text._content
      # xOffset: _model.get('x_coord')
      # yOffset: _model.get('y_coord')
    # p.linesOfText.push(_lineOfTextJSON)


  # # RFCTR widgets
  # # addWidget: (keyframe, widget) ->
    # # p = keyframe._paragraph
    # # throw new Error("Keyframe has no Paragraph") unless p?

    # # # FIXME Need a more generic way to add widgets to the JSON
    # # # FIXME TextWidget should be handled by KeyframesTextIndex
    # # if widget instanceof App.Views.TextWidget
      # # line =
        # # text: widget.getText()
        # # xOffset: Math.round(widget.x())
        # # yOffset: Math.round(widget.y())

      # # widget._line = line
      # # #TODO this logic should change according to new html text widgets
      # # p.linesOfText.push(line)

    # # widget.on('change', (property) => @updateWidget(keyframe, widget, property))

  # # createWidgetsFor: (owner) ->
    # # _.each(owner.widgets(), (widget) =>
      # # @createWidgetFor(owner, widget)
    # # )

  # # createWidgetFor: (owner, widget) ->
    # # this['add' + widget.type].call(this, widget)

  # # updateWidget: (keyframe, widget, property) ->
    # # p = keyframe._paragraph
    # # throw new Error("Keyframe has no Paragraph") unless p?

  # removeTextFromKeyframe: () ->
    # throw new Error("Not implemented yet")


  # getPage: (pageNumber) ->
    # @document.Pages[pageNumber]


  # addSprite: (sprite_widget) ->
    # page = sprite_widget.scene()._page
    # throw new Error("Scene has no Page") unless page?
    # page.API.CCSprites ||= []

    # spriteJSON =
      # image: sprite_widget.getUrl()
      # spriteTag: nextSpriteTag
      # position: []

    # page.API.CCSprites.push(spriteJSON)
    # sprite_widget._CCSprite = spriteJSON
    # sprite_widget.setTag(spriteJSON.spriteTag)
    # nextSpriteTag += 1
    # spriteJSON.spriteTag

  # addSpriteOrientationWidget: (sprite_orientation_widget) ->
    # ccsprite = sprite_orientation_widget.sprite_widget._CCSprite
    # throw new Error("SpriteWidget has no CCSprite") unless ccsprite?

    # if ccsprite.position.length == 0
      # ccsprite.position.push(parseInt(sprite_orientation_widget.point.x))
      # ccsprite.position.push(parseInt(sprite_orientation_widget.point.y))
    # else
      # page = sprite_orientation_widget.sprite_widget.scene()._page
      # throw new Error("Scene has no Page") unless page?
      # # Following should probably be ||= instead of =
      # page.API.CCMoveBy = []
      # spriteMoveByJSON =
        # position:  [parseInt(sprite_orientation_widget.point.x - ccsprite.position[0]), parseInt(sprite_orientation_widget.point.y - ccsprite.position[1])]
        # duration:  3
        # actionTag: nextActionTag
      # page.API.CCMoveBy.push(spriteMoveByJSON)
      # sprite_orientation_widget._CCMoveBy = spriteMoveByJSON
      # page.API.CCStorySwipeEnded ||= {}

      # # Following code is probably buggy.
      # # It does not account for multiple actionTags.
      # # page.API.CCStorySwipeEnded.runAction ||= []
      # # Following is a hack to for compilation. Above line should be used
      # page.API.CCStorySwipeEnded.runAction = []
      # runActionJSON =
        # runAfterSwipeNumber: 1
        # spriteTag:           ccsprite.spriteTag
        # actionTags:          [spriteMoveByJSON.actionTag]
      # page.API.CCStorySwipeEnded.runAction.push(runActionJSON)
      # nextActionTag += 1


  # updateSpriteOrientationWidget: (sprite_orientation_widget) ->
    # ccsprite = sprite_orientation_widget.sprite_widget._CCSprite
    # throw new Error("Scene has no Page") unless ccsprite?
    # if sprite_orientation_widget._CCMoveBy?
      # sprite_orientation_widget._CCMoveBy.position = [parseInt(sprite_orientation_widget.point.x - ccsprite.position[0]), parseInt(sprite_orientation_widget.point.y - ccsprite.position[1])]
      # sprite_orientation_widget._CCMoveBy.duration = 3

    # else
      # ccsprite.position[0] = parseInt(sprite_orientation_widget.point.x)
      # ccsprite.position[1] = parseInt(sprite_orientation_widget.point.y)


  # addSpriteWidget: (sprite_widget) ->
    # sprite_tag = @addSprite(sprite_widget)
    # _.each(sprite_widget.orientations(), (sprite_orientation_widget) =>
      # @addSpriteOrientationWidget(sprite_orientation_widget)
    # )
    # sprite_tag


  # addButtonWidget: (widget) ->
    # # TODO implement this
    # @addSpriteWidget(widget)


  # addTouchWidget: (touch_widget) ->
    # page = touch_widget.scene()._page
    # throw new Error("Scene has no Page") unless page?

    # page.API.CCStoryTouchableNode ||= {}
    # page.API.CCStoryTouchableNode.nodes ||= []

    # touchJSON =
      # glitterIndicator: true
      # stopEffectIndicator: false
      # touchFlag: nextTouchTag
      # position: [parseInt(touch_widget.getPosition().x), parseInt(touch_widget.getPosition().y)]
      # radius: touch_widget.getRadius()

    # if touch_widget.video_id?
      # touchJSON['videoToPlay'] = touch_widget.video_id
    # else if touch_widget.sound_id?
      # touchJSON['soundToPlay'] = touch_widget.sound_id

    # if touch_widget.action_id?
      # touchJSON['runAction'] = [{}]

    # page.API.CCStoryTouchableNode.nodes.push(touchJSON)

    # touch_widget._CCStoryTouchableNode = touchJSON
    # touch_widget.setTag(touchJSON.touchFlag)
    # nextTouchTag += 1
    # touchJSON.touchFlag

  # updateSprite: (scene, sprite) ->
    # page = scene._page

    # for spriteJSON in page.API.CCSprites
      # if spriteJSON.spriteTag == sprite.getTag()
        # spriteJSON.position = [parseInt(sprite.getPosition().x), parseInt(sprite.getPosition().y)]
        # spriteJSON.scale = sprite.getScale()

        # break

  # removeSprite: (sprite) ->
    # # TODO
