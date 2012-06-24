class App.StorybookJSON

  constructor: ->
    @Configurations =
      homeMenuForPages: {}
      pageFlipSound: {}
      pageFlipTransitionDuration: 0.5
      paragraphTextFadeDuration: 0.5

    @MainMenu =
      API: {}
      CCSprites: []
      MenuItems: []
      audio: {}
      runActionsOnEnter: []

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

  createPage: (scene) ->
    console.log('Create page', arguments)

    page =
      API: {}
      Page:
        settings: {}
        text:
          paragraphs: []

    scene._page = page
    @Pages.push(page)

    page

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

    paragraph

  getPage: (pageNumber) ->
    @document.Pages[pageNumber]
