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
    menuItem = new cc.MenuItemImage
    menuItem.initFromNormalImage(
      "/resources/#{@storybook.config.homeButtonNormalStateImage}"
      "/resources/#{@storybook.config.homeButtonTappedStateImage}"
      "/resources/#{@storybook.config.homeButtonTappedStateImage}"
      @storybook
      'showMainMenu'
    )

    menuItem.setPosition(@storybook.config.homeButtonPosition)

    @mainMenu = new cc.Menu
    @mainMenu.initWithItems([menuItem])

    @mainMenu.setPosition(new cc.Point(0, 0))

    @addChild(@mainMenu, 100)


  createSprites: ->
    console.log "About to create sprites"
    @page.sprites.forEach (spriteInfo) =>
      return unless spriteInfo

      if /^https?:\/\//.test(spriteInfo.image)
        spriteFile = spriteInfo.image
      else
        spriteFile = "/resources/#{spriteInfo.image}"

      cc.TextureCache.sharedTextureCache().addImage(spriteFile)

      # FIXME Can't be done with cocos2d-html5
      #unless path.exists(spriteFile)
      #  throw new Error("Unable to find Sprite file: " + spriteFile)

      sprite = new cc.Sprite
      sprite.initWithFile(spriteFile)
      sprite.setPosition(spriteInfo.position)
      sprite.setScale((spriteInfo.scale))
      @addChild(sprite, 10, spriteInfo.spriteTag)

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

    @addChild(menu, 100)

  onEnter: ->
    super
    @showParagraph(0)

  addParagraph: (paragraph) ->
    @paragraphs.push(paragraph)
    paragraph.setIsVisible(true)

    @addChild(paragraph, 50)


  showParagraph: (index) ->
    return if @_busyWithAction

    show = =>
      i = 0
      for p in @paragraphs
        p.setIsVisible((i is index))
        if p.getIsVisible() and @storybook.mainMenuLayer.storyMode is Sim.kStoryModeReadToMe
          p.startHighlight()
        else
          p.stopHighlight()

        i++

    hide = =>
      for p in @paragraphs
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
        , action.getDuration() * 1000
    else
      show()

    @currentParagraphNumber = index + 1

  showNextParagraph: ->
    return if @currentParagraphNumber is @paragraphs.length
    @showParagraph(@currentParagraphNumber)

  showPreviousParagraph: ->
    return if @currentParagraphNumber is 1
    @showParagraph(@currentParagraphNumber - 2)


