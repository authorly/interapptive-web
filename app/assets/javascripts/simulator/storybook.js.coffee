class Sim.Storybook

  constructor: (json) ->
    @config = {}
    @pages = []
    @currentPageNumber = 1

    @initFromJSON(json) if json


  initFromJSON: (json) ->
    struct = if typeof json == 'string' then JSON.parse(json) else json

    if not struct.Configurations then throw new Error("Storybook JSON doesn't contain a Configuration Object")
    if not struct.MainMenu       then throw new Error("Storybook JSON doesn't contain a MainMenu Object")
    if not struct.Pages          then throw new Error("Storybook JSON doesn't contain a Pages Array")

    @createConfig(struct.Configurations)
    @createMainMenu(struct.MainMenu)
    struct.Pages.forEach(@createPage.bind(this))

    @showMainMenu()


  createConfig: (configSrc) ->
    @config.forwardEffect = configSrc.pageFlipSound.forward
    @config.backwardEffect = configSrc.pageFlipSound.backward
    @config.pageFlipTransitionDuration = configSrc.pageFlipTransitionDuration
    @config.paragraphTextFadeDuration = configSrc.paragraphTextFadeDuration

    # Home button
    home = configSrc.homeMenuForPages
    @config.homeButtonNormalStateImage = home.normalStateImage
    @config.homeButtonTappedStateImage = home.tappedStateImage
    @config.homeButtonPosition = new cc.Point(home.position[0], home.position[1])


  createMainMenu: (menuSrc) ->
    page = @mainMenu = new Sim.MainMenu
    @pages[0] = page

    apiElement = menuSrc.API
    # TODO Audio
    # TODO runActionsOnEnter

    # Make API a little more like Page
    apiElement.CCSprites = menuSrc.CCSprites

    # Sprites -- TODO DRY with Page
    if apiElement.CCSprites
      apiElement.CCSprites.forEach (sprite) ->
        spriteInfo = new Sim.SpriteInfo

        spriteInfo.image = sprite.image
        spriteInfo.spriteTag = sprite.spriteTag
        spriteInfo.position = new cc.Point(sprite.position[0], sprite.position[1])

        # Sprite actions
        if sprite.actions
          for action in sprite.actions
            spriteInfo.actions.push(action)

        page.sprites.push(spriteInfo)



    # Actions
    for ccActionName of apiElement
      actionName = ccActionName.replace(/^CC/, '')
      ActionConst = cc[actionName]

      # Unknown action; skip it
      continue unless ActionConst

      apiElement[ccActionName].forEach (params) ->
        # Make position a real Point instance
        if params.position instanceof Array
          params.position = new cc.Point(params.position[0], params.position[1])

        if params.intensity
          params.scale = params.intensity

        action = new ActionConst(params)
        page.addAction(params.actionTag, action)



    # Menu Items
    if menuSrc.MenuItems
      menuSrc.MenuItems.forEach (menuItem) ->
        menuItemInfo = new Sim.MenuItem

        menuItemInfo.normalStateImage = menuItem.normalStateImage
        menuItemInfo.tappedStateImage = menuItem.tappedStateImage
        menuItemInfo.storyMode = menuItem.storyMode
        menuItemInfo.position = new cc.Point(menuItem.position[0], menuItem.position[1])

        page.menuItems.push menuItemInfo

  createPage: (pageSrc) ->
    page = new Sim.Page

    pageElement = pageSrc.Page
    apiElement = pageSrc.API

    # FIXME split all this logic into an external class

    # Parse Page

    page.settings = pageElement.settings

    rgb = page.settings.fontColor
    page.settings.fontColor = new cc.Color3B()
    page.settings.fontColor.r = rgb[0]
    page.settings.fontColor.g = rgb[1]
    page.settings.fontColor.b = rgb[2]

    rgb = page.settings.fontHighlightColor
    page.settings.fontHighlightColor = new cc.Color3B()
    page.settings.fontHighlightColor.r = rgb[0]
    page.settings.fontHighlightColor.g = rgb[1]
    page.settings.fontHighlightColor.b = rgb[2]

    page.settings.fontType = page.settings.fontType.split('.')[0]


    # Page text
    for paragraph in pageElement.text.paragraphs
      paragraphInfo = new Sim.ParagraphInfo
      page.paragraphs.push paragraphInfo

      paragraphInfo.highlightingTimes = paragraph.highlightingTimes.slice()

      paragraph.linesOfText.forEach (line) ->
        lineText = new Sim.LineText
        lineText.text = line.text
        lineText.xOffset = line.xOffset
        lineText.yOffset = line.yOffset

        paragraphInfo.linesOfText.push lineText

      paragraphInfo.voiceAudioFile = paragraph.voiceAudioFile


    # Parse API

    # Touchable nodes
    if apiElement.CCStoryTouchableNode
      for node in apiElement.CCStoryTouchableNode.nodes
        touchNode = new Sim.StoryTouchableNode
        touchNode.position = new cc.Point(node.position[0], node.position[1])

        ['glitterIndicator', 'radius', 'videoToPlay', 'soundToPlay', 'touchFlag'].forEach (key) ->
          touchNode[key] = node[key]

        if node.runAction
          node.runAction.forEach (runAction) ->
            touchNodeActionsToRun = new Sim.StoryTouchableNodeActionsToRun
            touchNodeActionsToRun.actionTag = runAction.actionTag
            touchNodeActionsToRun.spriteTag = runAction.spriteTag
            touchNode.actionsToRun.push touchNodeActionsToRun


        page.storyTouchableNodes.push touchNode

    # Sprites -- DRY with MainMenu
    if apiElement.CCSprites
      for sprite in apiElement.CCSprites
        spriteInfo = new Sim.SpriteInfo

        spriteInfo.image = sprite.image
        spriteInfo.spriteTag = sprite.spriteTag
        spriteInfo.position = new cc.Point(sprite.position[0], sprite.position[1])


        # Sprite actions
        if sprite.actions
          for action in sprite.actions
            spriteInfo.actions.push(action)

        page.sprites.push spriteInfo


    for ccActionName of apiElement
      actionName = ccActionName.replace(/^CC/, '')

      # Unknown action
      continue unless cc[actionName]

      for params in apiElement[ccActionName]
        # cocos2d-html5 doesn't support named arguments, so we need a huge
        # switch statement to handle argument order instead
        switch ccActionName
          when 'CCScaleBy'
            action = new cc.ScaleBy
            action.initWithDuration(params.duration, params.intensity)
          when 'CCMoveBy'
            if params.position
              p = new cc.Point(params.position[0], params.position[1])
            else
              p = new cc.Point(0, 0)

            action = new cc.MoveBy
            action.initWithDuration(params.duration, p)
          when 'CCMoveTo'
            if params.position
              p = new cc.Point(params.position[0], params.position[1])
            else
              p = new cc.Point(0, 0)

            action = new cc.MoveTo
            action.initWithDuration(params.duration, p)

        if action
          page.addAction(params.actionTag, action)


    # Swipe ended
    if apiElement.CCStorySwipeEnded
      runAction = apiElement.CCStorySwipeEnded.runAction
      for actionInfo in runAction
        action = new Sim.StorySwipeEndedActionsToRun
        action.runAfterSwipeNumber = actionInfo.runAfterSwipeNumber
        action.spriteTag = actionInfo.spriteTag
        action.actionTags = actionInfo.actionTags.slice()

        page.storySwipeEnded.actionsToRun.push action

      if apiElement.CCStorySwipeEnded.addChild
        childrenToAdd = apiElement.CCStorySwipeEnded.addChild.children
        page.storySwipeEnded.childrenToAdd = childrenToAdd.map((x) ->
          x.spriteTag
        )

      if apiElement.CCStorySwipeEnded.removeChild
        childrenToRemove = apiElement.CCStorySwipeEnded.removeChild.children
        page.storySwipeEnded.childrenToRemove = childrenToRemove.map((x) ->
          x.spriteTag
        )

    @setPage(page, page.settings.number)

    $(this).trigger('createpage',
      target: this
      pageNumber: pageSrc.Page.settings.number
      page: page
    )

  setPage: (page, number) ->
    number = number or @pages.length + 1
    @pages[number] = page

    $(this).trigger('setpage',
      target: this
      pageNumber: number
      page: page
    )


  showMainMenu: ->
    director = cc.Director.sharedDirector()

    scene = @createMainMenuScene()

    @currentPageNumber = 0

    director.replaceScene(scene)
    $(this).trigger('showmainmenu', target: this)


  showPage: (pageNumber) ->
    director = cc.Director.sharedDirector()
    scene = @createPageScene(pageNumber)

    throw new Error("Unable to find Page #{pageNumber}") unless scene

    @currentPageNumber = pageNumber

    director.replaceScene(scene)
    $(this).trigger("showpage",
      target: this
      pageNumber: pageNumber
    )

  createMainMenuScene: ->
    scene = new cc.Scene
    layer = @pageLayer = @mainMenuLayer = new Sim.MainMenuLayer(@mainMenu, this)

    scene.addChild(layer)

    @currentPageNumber = 0

    return scene


  createPageScene: (pageNumber) ->
    page = @pages[pageNumber]

    return unless page

    scene = new cc.Scene
    layer = @pageLayer = new Sim.PageLayer(page, this)

    scene.addChild(layer)

    @currentPageNumber = page.settings.number

    return scene

  showNextPage: ->
    page = @pages[@currentPageNumber]

    if @pageLayer.currentParagraphNumber is page.paragraphs.length
      return if @currentPageNumber is @pages.length
      @showPage(@currentPageNumber + 1)
    else
      @pageLayer.showNextParagraph()

  showPreviousPage: ->
    if @pageLayer.currentParagraphNumber is 1
      return if @currentPageNumber is 1
      @showPage(@currentPageNumber - 1)
    else
      @pageLayer.showPreviousParagraph()

