##
# This class is responsible for providing a structured JSON object
# to the Simulator as well as the Authorly mobile software.
#
# It creates the JSON structure from scratch each time it is created.
#
class App.JSON

  constructor: (storybook) ->
    @spriteIdCounter = new App.Lib.Counter
    @actionIdCounter = new App.Lib.Counter
    @hotspotIdCounter = new App.Lib.Counter

    @app =
      Configurations: @configurationNode(storybook)

    @storybook = storybook

    @initializeScenes()
    @resetScenes()

    @app


  initializeScenes: ->
    @scenes = @storybook.scenes


  resetScenes: ->
    @app.Pages = []
    # @scenesToJSON = {}

    @scenes.each (scene) =>
      if scene.isMainMenu()
        @app.MainMenu = @mainMenuNode(scene)
      else
        @addSceneNode(scene)


  addTextNodeFor: (keyframe, page) =>
    return if keyframe.isAnimation()

    textWidgets = keyframe.textWidgets()

    voiceoverNeeded = keyframe.scene.storybook.voiceoverNeeded()
    keyframeHighlightTimes = keyframe.get('content_highlight_times') if voiceoverNeeded
    keyframeHighlightTimes ||= []
    if keyframeHighlightTimes.length < 1 then keyframeHighlightTimes.push(0)
    if (voiceover = keyframe.voiceover())?
      keyframeVoiceoverUrl = voiceover.get('url')
    else
      keyframeVoiceoverUrl = undefined

    paragraph =
      linesOfText: textWidgets.map (widget) ->
        color = widget.get('font_color')
        position = widget.get('position')

        text: widget.get('string'),
        xOffset: Math.round(position.x),
        yOffset: Math.round(position.y),
        fontType: widget.fontFileName(),
        fontColor: [color.r, color.g, color.b],
        fontHighlightColor: [255, 0, 0],
        fontSize: Number(widget.get('font_size'))
      hotspots: keyframe.hotspotWidgets().map (widget) =>
        position = widget.get('position')
        hash =
          glitterIndicator: true
          stopEffectIndicator: false
          touchFlag: @hotspotIdCounter.next()
          position: @_getPosition(position)
          radius:   Math.round(widget.get('radius'))
        assetKey = if widget.hasSound() then 'soundToPlay' else 'videoToPlay'
        hash[assetKey] = widget.assetUrl()
        hash

      highlightingTimes: keyframeHighlightTimes
      autoplayDuration: keyframe.autoplayDuration()

    paragraph.voiceAudioFile = keyframeVoiceoverUrl if voiceoverNeeded

    if textWidgets.length == 0
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
      Page:
        settings:
          number: scene.get('position') + 1
        text:
          paragraphs: []
    if (sound = scene.sound())?
      page.Page.settings.backgroundMusicFile =
        loop: if scene.get('loop_sound') then 1 else 0
        audioFilePath: sound.get('url')
    scene.keyframes.each (k) => @addTextNodeFor(k, page)

    @app.Pages.push(page)

    @addSpriteNodesFor(scene, page)


  addSpriteNodesFor: (scene, page) ->
    page.API.CCSprites ||= []

    _.each scene.spriteWidgets(), (spriteWidget) =>
      position = scene.keyframes.at(0).getOrientationFor(spriteWidget).get('position')
      spriteId = @spriteIdCounter.next() * 10
      spriteNode =
        image:     spriteWidget.url()
        spriteTag: spriteId
        # TODO does the app require this? because we have a Move action for the first
        # keyframe anyway
        position: @_getPosition(position)
      page.API.CCSprites.push(spriteNode)

      actions = page.API.CCStorySwipeEnded.runAction
      previousOrientation = null
      animationNode = null
      scene.keyframes.each (keyframe, index) =>
        orientation = keyframe.getOrientationFor(spriteWidget)
        keyframeIndex = keyframe.get('position')

        keyframeIsAnimation = keyframe.isAnimation() || keyframeIndex == 0 and index == 0
        if keyframeIsAnimation
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

          if keyframeIsAnimation and duration == 0
            initialScaleActionId = scaleId

        moveId = null
        previousPosition = previousOrientation?.get('position')
        position = orientation.get('position')
        unless previousOrientation? && previousPosition.x == position.x && previousPosition.y == position.y
          moveId = @actionIdCounter.next()
          page.API.CCMoveTo.push
            actionTag: moveId
            duration: duration
            position: @_getPosition(position)

        if keyframe.get('is_animation')
          delayId = @actionIdCounter.next()
          page.API.CCDelayTime.push
            actionTag: delayId
            duration: keyframe.get('animation_duration')

          spawnId = @actionIdCounter.next()
          animationNode =
            actionTag: spawnId
            actions: []
          page.API.CCSpawn.push animationNode

          sequenceId = @actionIdCounter.next()
          page.API.CCSequence.push
            actionTag: sequenceId
            actions: [delayId, spawnId]

          spriteNode.actions = [initialScaleActionId, sequenceId]
        else
          currentActions = _.without [scaleId, moveId], null
          if currentActions.length > 0
            if keyframeIndex == 0 and index == 0
              spriteNode.actions = currentActions

            else if keyframeIndex > 0
              actions.push
                runAfterSwipeNumber: keyframe.get('position')
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
      retainTextScalingRatio: true
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
        position: @_getPosition(homeButtonPosition)
        scale: home.get('scale')
    node


  mainMenuNode: (scene) ->
    str = App.Lib.StringHelper
    node =
      # audio:
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
        _.select(scene.buttonWidgets(), (w) -> !w.disabled()).map (button) =>
          {
            normalStateImage: button.url()
            tappedStateImage: button.selectedUrl() || button.url()
            storyMode: str.decapitalize(str.camelize(button.get('name')))
            position: @_getPosition(button.get('position'))
            scale: button.get('scale')
            zOrder: parseInt(button.get('z_order'))
          }

      API: {}

    _.each scene.spriteWidgets(), (spriteWidget) =>
      spriteId = @spriteIdCounter.next()
      orientation = scene.keyframes.at(0).getOrientationFor(spriteWidget)
      spriteNode =
        image:     spriteWidget.url()
        spriteTag: spriteId
        scale:     orientation.get('scale')
        position:  @_getPosition(orientation.get('position'))
        visible:   true
        zOrder:   parseInt(spriteWidget.get('z_order'))
      node.CCSprites.push(spriteNode)

    if (sound = scene.sound())?
      node.audio =
        backgroundMusic      : sound.get('url')
        backgroundMusicLoops : if scene.get('loop_sound') then 0 else 1

    node


  _getPosition: (position) ->
    [Math.round(position.x), Math.round(position.y)]

