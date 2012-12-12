nextSpriteTag = 1
nextActionTag = 1
nextTouchTag  = 1

class App.StorybookJSON

  constructor: ->

    # The object that will become the JSON string
    @document =
      Configurations:
        pageFlipSound:
          forward: "page-flip-sound.mp3"
          backward: "page-flip-sound.mp3"

        pageFlipTransitionDuration: 0.6
        paragraphTextFadeDuration: 0.4
        homeMenuForPages:
          normalStateImage: "home-button.png"
          tappedStateImage: "home-button-over.png"
          position: [20, 20]

      MainMenu:
        CCSprites: [],
        MenuItems: [{
            normalStateImage: "autoplay.png",
            tappedStateImage: "autoplay-over.png",
            storyMode: "autoPlay",
            position: [100, 112]
        }, {
            normalStateImage: "read-it-myself.png",
            tappedStateImage: "read-it-myself-over.png",
            storyMode: "readItMyself",
            position: [400, 112]
        }, {
            normalStateImage: "read-to-me.png",
            tappedStateImage: "read-to-me-over.png",
            storyMode: "readToMe",
            position: [700, 112]
        }],
        API: {
            CCFadeIn: [{
                duration: 2,
                actionTag: 22
            }]
        },
        runActionsOnEnter: [{
            spriteTag: 100,
            actionTag: 22
        }]

      Pages: []


  @fromJSON: (json) ->
    # TODO


  toString: ->
    JSON.stringify(@document)


  resetPages: ->
    @document.Pages = []


  resetParagraphs: (scene) ->
    page = scene._page
    page.Page.text.paragraphs = [] if page?


  # scene === page
  createPage: (scene) ->

    page =
      API: {}
      Page:
        settings:
          number: @document.Pages.length + 1,
          fontType: "Arial",
          fontColor: [255, 0, 0],
          fontHighlightColor: [255, 255, 255],
          fontSize: 24,
          backgroundMusicFile:
            loop: true,
            audioFilePath: scene.get('sound_url')
        text:
          paragraphs: []

    scene._page = page
    @createWidgetsFor(scene)
    @createParagraphsFor(scene)
    @document.Pages.push(page)
    page

  destroyPage: (scene) ->
    page = scene._page
    throw new Error("Scene has no Page") unless page?
    @document.Pages.splice(@document.Pages.indexOf(page), 1)
    @_updatePageNumbers(page.Page.settings.number)

  _updatePageNumbers: (from_number) ->
    _.each(@document.Pages, (page) ->
      if page.Page.settings.number > from_number
        page.Page.settings.number = page.Page.settings.number - from_number
    )

  createParagraphsFor: (scene) ->
    scene.keyframes.each (keyframe) =>
      @createParagraph(scene, keyframe)

  createWidgetsFor: (owner) ->
    _.each(owner.widgets(), (widget) =>
      @createWidgetFor(owner, widget)
    )

  createWidgetFor: (owner, widget) ->
    this['add' + widget.constructor.name].call(this, widget)

  # keyframe === paragraph
  createParagraph: (scene, keyframe) ->
    page = scene._page
    throw new Error("Scene has no Page") unless page?
    return false if keyframe.texts.length == 0

    paragraph =
      delayForPanning: true
      highlightingTimes: _.map(keyframe.get('content_highlight_times'), (num) -> Number(num))
      linesOfText: keyframe.texts.pluckContent()
      voiceAudioFile: keyframe.get('url')

    page.Page.text.paragraphs.push(paragraph)
    keyframe._paragraph = paragraph
    @createWidgetsFor(keyframe)
    paragraph

  removeParagraph: (scene, keyframe) ->
    page = scene._page
    throw new Error("Scene has no Page") unless page?
    page.Page.text.paragraphs.splice(page.Page.text.paragraphs.indexOf(keyframe._paragraph), 1)

  updateParagraph: (keyframe) ->
    keyframe._paragraph.highlightingTimes = _.map(keyframe.get('content_highlight_times'), (num) -> Number(num))
    keyframe._paragraph.linesOfText       = keyframe.texts.pluckContent()
    keyframe._paragraph.voiceAudioFile    = keyframe.get('url')

  addText: (_text, keyframe) ->
    keyframe ||= App.currentKeyframe()

    p = keyframe._paragraph
    throw new Error("Keyframe has no Paragraph") unless p?

    _model = _text.model
    _lineOfTextJSON =
      text:    _text._content
      xOffset: _model.get('x_coord')
      yOffset: _model.get('y_coord')
    p.linesOfText.push(_lineOfTextJSON)


  addWidget: (keyframe, widget) ->
    p = keyframe._paragraph
    throw new Error("Keyframe has no Paragraph") unless p?

    # FIXME Need a more generic way to add widgets to the JSON
    # FIXME TextWidget should be handled by KeyframesTextIndex
    if widget instanceof App.Views.TextWidget
      line =
        text: widget.getText()
        xOffset: Math.round(widget.x())
        yOffset: Math.round(widget.y())

      widget._line = line
      #TODO this logic should change according to new html text widgets
      p.linesOfText.push(line)

    widget.on('change', (property) => @updateWidget(keyframe, widget, property))


  updateWidget: (keyframe, widget, property) ->
    p = keyframe._paragraph
    throw new Error("Keyframe has no Paragraph") unless p?

  removeTextFromKeyframe: () ->
    throw new Error("Not implemented yet")


  getPage: (pageNumber) ->
    @document.Pages[pageNumber]


  addSprite: (sprite_widget) ->
    page = sprite_widget.scene()._page
    throw new Error("Scene has no Page") unless page?
    page.API.CCSprites ||= []

    spriteJSON =
      image: sprite_widget.getUrl()
      spriteTag: nextSpriteTag
      position: []

    page.API.CCSprites.push(spriteJSON)
    sprite_widget._CCSprite = spriteJSON
    sprite_widget.setTag(spriteJSON.spriteTag)
    nextSpriteTag += 1
    spriteJSON.spriteTag

  addSpriteOrientationWidget: (sprite_orientation_widget) ->
    ccsprite = sprite_orientation_widget.sprite_widget._CCSprite
    throw new Error("SpriteWidget has no CCSprite") unless ccsprite?

    if ccsprite.position.length == 0
      ccsprite.position.push(sprite_orientation_widget.point.x)
      ccsprite.position.push(sprite_orientation_widget.point.y)
    else
      page = sprite_orientation_widget.sprite_widget.scene()._page
      throw new Error("Scene has no Page") unless page?
      page.API.CCMoveTo ||= []
      spriteMoveToJSON =
        position:  [sprite_orientation_widget.point.x, sprite_orientation_widget.point.y]
        duration:  3
        actionTag: nextActionTag
      page.API.CCMoveTo.push(spriteMoveToJSON)
      sprite_orientation_widget._CCMoveTo = spriteMoveToJSON

      # Following code is probably buggy.
      # It does not account fro multiple actionTags.
      page.API.runAction ||= []
      runActionJSON =
        runAfterSwipeNumber: 1
        spriteTag:           ccsprite.spriteTag
        actionTags:          [spriteMoveToJSON.actionTag]
      page.API.runAction.push(runActionJSON)
      nextActionTag += 1

  addSpriteWidget: (sprite_widget) ->
    sprite_tag = @addSprite(sprite_widget)
    _.each(sprite_widget.orientations(), (sprite_orientation_widget) =>
      @addSpriteOrientationWidget(sprite_orientation_widget)
    )
    sprite_tag

  addTouchWidget: (touch_widget) ->
    page = touch_widget.scene()._page
    throw new Error("Scene has no Page") unless page?

    page.API.CCStoryTouchableNode ||= {}
    page.API.CCStoryTouchableNode.nodes ||= []

    touchJSON =
      glitterIndicator: true
      stopEffectIndicator: false
      touchFlag: nextTouchTag
      position: [touch_widget.getControlCenter().x, touch_widget.getControlCenter().y]
      radius: touch_widget.getRadius()

    if touch_widget.video_id?
      touchJSON['videoToPlay'] = touch_widget.video_id
    else if touch_widget.audio_id?
      touchJSON['soundToPlay'] = touch_widget.audio_id

    if touch_widget.action_id?
      touchJSON['runAction'] = [{}]

    page.API.CCStoryTouchableNode.nodes.push(touchJSON)

    touch_widget._CCStoryTouchableNode = touchJSON
    touch_widget.setTag(touchJSON.touchFlag)
    nextTouchTag += 1
    touchJSON.touchFlag

  updateSprite: (scene, sprite) ->
    page = scene._page

    for spriteJSON in page.API.CCSprites
      if spriteJSON.spriteTag == sprite.getTag()
        spriteJSON.position = [sprite.getPosition().x, sprite.getPosition().y]
        spriteJSON.scale = sprite.getScale()

        break

  removeSprite: (sprite) ->
    # TODO
