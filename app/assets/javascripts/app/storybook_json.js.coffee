nextSpriteTag = 1

class App.StorybookJSON

  constructor: ->

    # The object athat will become the JSON string
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
    # FIXME needs to delete scene._page
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
          fontSize: 28,
          backgroundMusicFile:
            loop: true,
            audioFilePath: "background.mp3"

        text:
          paragraphs: []

    scene._page = page
    @document.Pages.push(page)

    page


  # keyframe === paragraph
  createParagraph: (scene, keyframe) ->

    page = scene._page
    throw new Error("Scene has no Page") unless page?

    paragraph =
      delayForPanning: true
      highlightingTimes: []
      linesOfText: []
      voiceAudioFile: ""

    page.Page.text.paragraphs.push(paragraph)

    keyframe._paragraph = paragraph

    paragraph


  addText: (text, keyframe) ->
    keyframe ||= App.currentKeyframe()

    p = keyframe._paragraph
    throw new Error("Keyframe has no Paragraph") unless p?

    console.log "storybookJSON.addText() text: ", text

    p.linesOfText.push(text)


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

    # FIXME Need a more generic way to add widgets to the JSON
    #if widget instanceof App.Views.TextWidget
      #if widget._line
        # FIXME solve for multiple line widget.text()
        #widget._line.text    = widget.text()
        #widget._line.xOffset = Math.round(widget.x())
        #widget._line.yOffset = Math.round(widget.y())


  removeTextFromKeyframe: () ->
    throw new Error("Not implemented yet")


  getPage: (pageNumber) ->
    @document.Pages[pageNumber]


  addSprite: (scene, sprite) ->
    page = scene._page

    page.API.CCSprites ||= []

    # Hardcoded actions
    ###
    page.API.CCMoveBy = [{
      position: [-810, 100],
      duration: 3,
      actionTag: 30
    }]
    page.API.CCScaleBy = [{
      intensity: 1.4,
      duration: 3,
      actionTag: 31
    }, {
      intensity: 1.0,
      duration: 0,
      actionTag: 32
    }, {
      intensity: 1.4,
      duration: 3,
      actionTag: 34
    }]
    page.API.CCStorySwipeEnded = {
      runAction: [{
        runAfterSwipeNumber: 1,
        spriteTag: nextSpriteTag,
        actionTags: [30, 34]
      }]
    }
    ###

    spriteJSON =
      image:     sprite.getUrl()
      spriteTag: nextSpriteTag
      position:  [sprite.getPosition().x, sprite.getPosition().y]
      scale:     sprite.getScale()

      #actions: [32]

    page.API.CCSprites.push(spriteJSON)

    sprite.setTag(spriteJSON.spriteTag)

    nextSpriteTag += 1
    return spriteJSON.spriteTag


  updateSprite: (scene, sprite) ->
    page = scene._page

    for spriteJSON in page.API.CCSprites
      if spriteJSON.spriteTag == sprite.getTag()
        spriteJSON.position = [sprite.getPosition().x, sprite.getPosition().y]
        spriteJSON.scale = sprite.getScale()

        break


  removeSprite: (sprite) ->
    # TODO
