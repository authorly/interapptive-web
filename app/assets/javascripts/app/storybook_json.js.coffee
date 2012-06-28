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

  # scene === page
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
