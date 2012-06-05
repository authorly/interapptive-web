class Sim.PageLayer extends cc.Scene

  constructor: (page, storybook) ->
    super

    @storybook = storybook
    @page = page
    @paragraphs = []

    @createSprites()
    @createParagraphs()
    @createTouchNodes()
    @createMainMenuItem()

  createMainMenuItem: ->
    menuItem = cc.MenuItemImage.itemFromNormalImage(
      "/resources/#{@storybook.config.homeButtonNormalStateImage}"
      "/resources/#{@storybook.config.homeButtonTappedStateImage}"
      @storybook
      'showMainMenu'
    )

    menuItem.setPosition(@storybook.config.homeButtonPosition)

    mainMenu = @mainMenu = new cc.Menu
    mainMenu.initWithItems([menuItem])

    mainMenu.setPosition(new cc.Point(0, 0))

    @addChild(mainMenu)


  createSprites: ->
    @page.sprites.forEach (spriteInfo) =>
      return unless spriteInfo

      spriteFile = "/resources/#{spriteInfo.image}"

      # FIXME Can't be done with cocos2d-html5
      #unless path.exists(spriteFile)
      #  throw new Error("Unable to find Sprite file: " + spriteFile)

      sprite = cc.Sprite.spriteWithFile(spriteFile)
      sprite.setPosition(spriteInfo.position)

      @addChild(sprite, 1, spriteInfo.spriteTag)

  createParagraphs: ->
    @page.paragraphs.forEach (paragraphInfo) =>
      paragraph = new Sim.Paragraph(paragraphInfo)

      paragraph.fontColor = @page.settings.fontColor
      paragraph.fontHighlightColor = @page.settings.fontHighlightColor
      paragraph.fontSize = @page.settings.fontSize
      paragraph.fontName = @page.settings.fontType

      @addParagraph(paragraph)

  createTouchNodes: ->
    items = []


    @page.storyTouchableNodes.forEach (touchNode) ->
      menuItem = new cc.MenuItemImage(
        normalImage: "/resources/r1.png"
        selectedImage: "/resources/r2.png"
        callback: ->
      )

      menuItem.setPosition(touchNode.position)
      menuItem.setContentSize(new cc.Size(touchNode.radius * 2, touchNode.radius * 2))
      items.push(menuItem)

    menu = @touchNodeMenu = new cc.Menu(items: items)
    menu.setPosition(new cc.Point(0, 0))

    @addChild(menu, 1)

  onEnter: ->
    super
    @showParagraph(0)

  addParagraph: (paragraph) ->
    @paragraphs.push(paragraph)
    paragraph.setIsVisible(true)

    @addChild(paragraph, 100)


  showParagraph: (index) ->
    return if @_busyWithAction

    show = =>
      i = 0
      @paragraphs.forEach (p) =>
        p.setIsVisible((i is index))
        if p.getIsVisible() and @storybook.mainMenuLayer.storyMode is Sim.kStoryModeReadToMe
          p.startHighlight()
        else
          p.stopHighlight()

        i++

    hide = =>
      @paragraphs.forEach (p) =>
        p.setIsVisible(false)
        p.stopHighlight()


    swipeLeft = index + 1 > @currentParagraphNumber

    actionsToRun = @page.getStorySwipeEndedActionToRun(@currentParagraphNumber - (if swipeLeft then 0 else 1))

    if index + 1 isnt @currentParagraphNumber and actionsToRun.length > 0
      hide()

      actionsToRun.forEach (actionToRun) =>
        @_busyWithAction = true
        sprite = @getChildByTag(actionToRun.spriteTag)
        throw new Error("Unable to find sprite with tag: " + actionToRun.spriteTag)  unless sprite

        if actionToRun.actionTags.length > 1
          actions = actionToRun.actionTags.map(@page.getActionByTag.bind(@page))
          action = cc.Spawn.actionsWithArray(actions)
        else
          action = @page.getActionByTag(actionToRun.actionTags[0])

        if swipeLeft
          sprite.runAction(action)
        else
          sprite.runAction(action.reverse())

        setTimeout =>
          show()
          @_busyWithAction = false
        , action.duration * 1000
    else
      show()

    @currentParagraphNumber = index + 1

  showNextParagraph: ->
    return if @currentParagraphNumber is @paragraphs.length
    @showParagraph(@currentParagraphNumber)

  showPreviousParagraph: ->
    return if @currentParagraphNumber is 1
    @showParagraph(@currentParagraphNumber - 2)


