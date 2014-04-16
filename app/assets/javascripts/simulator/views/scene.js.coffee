class Sim.Views.Scene extends cc.Scene

  constructor: (scene, homeMenu)->
    super
    @scene = scene
    @homeMenuModel = homeMenu

    @_preloadSounds()
    @currentActions = []

    zOrder = 1
    background = cc.LayerColor.create(new cc.c4b(255, 255, 255, 255))
    @addChild background, (zOrder = zOrder + 1)

    @spritesLayer = new Sim.Views.SpritesLayer(@scene.sprites)
    @addChild @spritesLayer, (zOrder = zOrder + 1)

    @textsLayer = new Sim.Views.TextsLayer()
    @addChild @textsLayer, (zOrder = zOrder + 1)
    @textsLayer.setVisible false

    @hotspotsLayer = new Sim.Views.HotspotsLayer
      particlesDefinitionFile: Sim.config.particleSystemDefinition
    @hotspotsLayer.setVisible false
    @addChild @hotspotsLayer, (zOrder = zOrder + 1)

    @homeMenu = @initHomeMenu(@homeMenuModel)
    @addChild @homeMenu, (zOrder = zOrder + 1)

    # TODO should be loaded at this point
    @currentKeyframeIndex = 0
    @spritesLayer.initialize()
    @_delayCallback(@finishedIntro, @scene.introDuration)



  finishedIntro: ->
    @textsLayer.setVisible true
    @hotspotsLayer.setVisible true
    @showKeyframe(0)


  getNumber: ->
    @scene.number


  next: ->
    return false unless @currentKeyframeIndex + 1 < @scene.keyframes.length

    if @inAction()
      @clear()
    else
      @clear()
      @swipeToNextKeyframe()

    true


  back: ->
    return false unless @currentKeyframeIndex - 1 >= 0

    @clear()

    @showKeyframe(@currentKeyframeIndex - 1)
    true


  showKeyframe: (index) ->
    @currentKeyframeIndex = index
    keyframe = @scene.keyframes[@currentKeyframeIndex]

    @textsLayer.show keyframe.texts
    @hotspotsLayer.show keyframe.hotspots


  inAction: ->
    _.some @currentActions, (action) -> not action.action.isDone()


  clear: ->
    @cleanup()
    cc.AudioEngine.getInstance().pauseMusic()

    @textsLayer.clear()
    @hotspotsLayer.clear()

    @spritesLayer.finishAllActions()

    for action in @currentActions
      unless action.action.isDone()
        action.callback.call(@)

    @currentActions = []


  swipeToNextKeyframe: ->
    keyframe = @scene.keyframes[@currentKeyframeIndex]
    @spritesLayer.runSwipeActions(keyframe.swipeActions)

    durations = _.map keyframe.swipeActions, (action) -> action.duration
    duration = _.max durations

    @_delayCallback @showNextKeyframe, duration


  showNextKeyframe: ->
    @showKeyframe(@currentKeyframeIndex + 1)


  initHomeMenu: (model) ->
    home = cc.MenuItemImage.create(model.url, model.tappedUrl, Sim.storybook.home, Sim.storybook)
    home.setPosition(model.position)
    home.setScale(model.scale)

    menu = cc.Menu.create([home])
    menu.setPosition(new cc.Point(0, 0))
    menu


  _preloadSounds: ->
    sounds = []
    if (background = @scene.backgroundMusic)?
      sounds.push type: 'bgm', src: Sim.util.httpPath(background.audioFilePath)

    for keyframe in @scene.keyframes
      for hotspot in keyframe.hotspots
        if hotspot.soundToPlay?
          sounds.push type: 'effect', src: hotspot.soundUrl

    if sounds.length > 0
      cc.Loader.preload sounds, @_soundsLoaded, @


  _soundsLoaded: ->
    if (background = @scene.backgroundMusic)?
      # XXX hack without this timeout, music does not play
      # @dira 2014-05-01
      window.setTimeout ( ->
        path = Sim.util.httpPath(background.audioFilePath)
        cc.AudioEngine.getInstance().playMusic(path, background.loop == 1)
      ), 150


  _delayCallback: (callback, delay) ->
    delayedAction = cc.Sequence.create(cc.DelayTime.create(delay),
      cc.CallFunc.create(callback, @)
    )
    @runAction delayedAction
    @currentActions.push
      action: delayedAction
      callback: callback


