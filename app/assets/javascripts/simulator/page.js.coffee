class Sim.LineText

  constructor: ->
    @text = ''

  words: ->
    return @text.split(' ')


class Sim.ParagraphInfo

  constructor: ->
    @linesOfText = []


class Sim.SpriteInfo

  constructor: ->
    @image = ''
    @spriteTag = null
    @position = new cc.Point(0, 0)
    @actions = []


class Sim.StorySwipeEndedActionsToRun

  constructor: ->
    @actionTags = []


class Sim.StorySwipeEnded

  constructor: ->
    @spritesToAdd  = []
    @spritesToMove = []
    @actionsToRun  = []


class Sim.StoryTouchableNode

  constructor: ->
    @actionsToRun     = []
    @glitterIndicator = false
    @radius           = 32
    @position         = null
    @videoToPlay      = ''
    @soundToPlay      = ''
    @touchFlag        = false


class Sim.StoryTouchableNodeActionsToRun

  constructor: ->
    @spriteTag = null
    @actionTag = null


class Sim.Page

  constructor: ->
    @settings   = {}
    @actions    = []
    @paragraphs = []
    @sprites    = []
    @storyTouchableNodes = []
    @storySwipeEnded = new Sim.StorySwipeEnded


  getStorySwipeEndedActionToRun: (swipeNumber) ->
    swipeNumber = swipeNumber or 0

    actionsToRun = []

    @storySwipeEnded.actionsToRun.forEach (action) ->
      if action.runAfterSwipeNumber is swipeNumber
        actionsToRun.push(action)

    return actionsToRun


  addAction: (tag, action) ->
    @actions[tag] = action


  getActionByTag: (tag) ->
    @actions[tag]


  getSpriteInfoByTag: (tag) ->
    @sprites[tag]
