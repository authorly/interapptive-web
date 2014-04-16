class Sim.Models.ActionParser

  constructor: (json) ->
    @json = json
    @_actionData = {}
    @_actions = {}
    @_actionDuration = {}

    @swipes = {}
    @spriteActions = {}


  run: ->
    @_indexActions()

    for tag, action of @_actionData
      @_ensureActionCreated(tag)

    for swipeJson in @json.CCStorySwipeEnded.runAction
      @_createSwipeAction(swipeJson)

    for json in @json.CCSprites
      @spriteActions[json.spriteTag] =
        action: cc.Spawn.create @_getActions(json.actions)
        finalOrientation: @_getOrientation(json.actions)


  getIntroDuration: ->
    actionTags = _.flatten(_.map @json.CCSprites, (json) => json.actions)
    durations = _.map actionTags, (tag) => @_actionDuration[tag]
    _.max durations


  _indexActions: ->
    for kind in ['CCDelayTime', 'CCMoveTo', 'CCScaleTo', 'CCSpawn', 'CCSequence']
      for actionJson in @json[kind]
        @_actionData[actionJson.actionTag] = Sim.Models.Action.createFromJson(actionJson, kind)


  _ensureActionCreated: (tag) ->
    return if @_actions[tag]?

    action = @_actionData[tag]
    @_actions[tag] = switch action.kind
      when 'CCMoveTo'
        cc.MoveTo.create(action.duration, action.position)
      when 'CCScaleTo'
        cc.ScaleTo.create(action.duration, action.intensity, action.intensity)
      when 'CCDelayTime'
        cc.DelayTime.create(action.duration)
      when 'CCSpawn'
        for spawnedActionTag in action.actions
          @_ensureActionCreated(spawnedActionTag)
        cc.Spawn.create @_getActions(action.actions)
      when 'CCSequence'
        for spawnedActionTag in action.actions
          @_ensureActionCreated(spawnedActionTag)
        cc.Sequence.create @_getActions(action.actions)

    @_actionDuration[tag] = switch action.kind
      when 'CCMoveTo', 'CCScaleTo', 'CCDelayTime'
        action.duration
      when 'CCSpawn'
        durations = _.map action.actions, (tag) => @_actionDuration[tag]
        _.max durations
      when 'CCSequence'
        durations = _.map action.actions, (tag) => @_actionDuration[tag]
        _.reduce durations, ((sum, duration) -> sum + duration), 0


  _createSwipeAction: (json) ->
    index = json.runAfterSwipeNumber
    actions = @_getActions(json.actionTags)
    durations = _.map json.actionTags, (tag) => @_actionDuration[tag]
    duration = _.max durations
    action = if actions.length > 1
      cc.Spawn.create actions
    else
      actions[0]

    @swipes[index] ||= {}
    @swipes[index][json.spriteTag] =
      action: action
      duration: duration
      finalOrientation: @_getOrientation(json.actionTags)


  _getActions: (tags) ->
    _.map tags, (tag) => @_actions[tag]


  _getOrientation: (tags) ->
    orientation = {}

    for tag in tags
      action = @_actionData[tag]
      switch action.kind
        when 'CCMoveTo'
          orientation.position = action.position
        when 'CCScaleTo'
          orientation.scale = action.intensity
        when 'CCSpawn', 'CCSequence'
          for spawnedActionTag in action.actions
            _.extend(orientation, @_getOrientation([spawnedActionTag]))

    orientation
