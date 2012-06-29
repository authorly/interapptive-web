nextSpriteTag = 1

class App.StorybookJSON

  constructor: ->
    @Configurations =
      pageFlipSound:
        forward: "page-flip-sound.mp3"
        backward: "page-flip-sound.mp3"

      pageFlipTransitionDuration: 0.6
      paragraphTextFadeDuration: 0.4
      homeMenuForPages:
        normalStateImage: "home-button.png"
        tappedStateImage: "home-button-over.png"
        position: [20, 20]

    @MainMenu =
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

    @Pages = []

  @fromJSON: (json) ->
    # TODO

  toString: ->
    JSON.stringify(this)

  resetPages: ->
    # FIXME needs to delete scene._page
    @Pages = []

  resetParagraphs: (scene) ->
    page = scene._page
    page.Page.text.paragraphs = [] if page?

  # scene === page
  createPage: (scene) ->
    console.log('Create page', arguments)

    page =
      API: {}
      Page:
        settings:
          number: 1,
          fontType: "PoeticaChanceryIII.ttf",
          fontColor: [255, 255, 255],
          fontHighlightColor: [255, 0, 0],
          fontSize: 48,
          backgroundMusicFile:
            loop: true,
            audioFilePath: "background.mp3"

        text:
          paragraphs: []

    scene._page = page
    @Pages.push(page)

    page

  # keyframe === paragraph
  createParagraph: (scene, keyframe) ->
    console.log('Create paragraph', arguments)

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

  addWidget: (keyframe, widget) ->
    p = keyframe._paragraph
    throw new Error("Keyframe has no Paragraph") unless p?

    # FIXME Need a more generic way to add widgets to the JSON
    if widget instanceof App.Builder.Widgets.TextWidget
      line =
        text: widget.label.getString()
        xOffset: Math.round(widget.getPosition().x)
        yOffset: Math.round(widget.getPosition().y)

      widget._line = line

      p.linesOfText.push(line)

    widget.on('change', (property) => @updateWidget(keyframe, widget, property))

  updateWidget: (keyframe, widget, property) ->
    p = keyframe._paragraph
    throw new Error("Keyframe has no Paragraph") unless p?

    # FIXME Need a more generic way to add widgets to the JSON
    if widget instanceof App.Builder.Widgets.TextWidget
      if widget._line
        widget._line.text    = widget.label.getString()
        widget._line.xOffset = Math.round(widget.getPosition().x)
        widget._line.yOffset = Math.round(widget.getPosition().y)



  getPage: (pageNumber) ->
    @document.Pages[pageNumber]

  addSprite: (scene, sprite) ->
    page = scene._page

    page.API.CCSprites ||= []

    debugger
    spriteJSON =
      image: sprite.url
      spriteTag: nextSpriteTag++
      position: [sprite.getPosition().x, sprite.getPosition().y]

    page.API.CCSprites.push(spriteJSON)

    sprite.setTag(spriteJSON.spriteTag)

    return spriteJSON.spriteTag

  updateSprite: (scene, sprite) ->
    page = scene._page

    for spriteJSON in page.API.CCSprites
      if spriteJSON.spriteTag == sprite.getTag()
        spriteJSON.position = [sprite.getPosition().x, sprite.getPosition().y]
        break

  removeSprite: (sprite) ->
    # TODO
