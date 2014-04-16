class Sim.Views.MainMenuScene extends cc.Scene

  constructor: (menu)->
    super
    @menu = menu
    @_preloadSounds()

    zOrder = 1
    background = cc.LayerColor.create(new cc.c4b(255, 255, 255, 255))
    @addChild background, (zOrder = zOrder + 1)

    spritesLayer = new Sim.Views.SpritesLayer(@menu.sprites)
    @addChild spritesLayer, (zOrder = zOrder + 1)

    @mainMenuLayer = new Sim.Views.MainMenuLayer(@menu.items)
    @mainMenuLayer.setPosition(new cc.Point(0, 0))
    @addChild @mainMenuLayer, (zOrder = zOrder + 1)


  cleanup: ->
    cc.AudioEngine.getInstance().pauseMusic()
    cc.AudioEngine.getInstance().pauseAllEffects()


  _preloadSounds: ->
    soundsModel = @menu.sounds
    return unless soundsModel?

    sounds = []
    if soundsModel.background?
      sounds.push type: 'bgm', src: Sim.util.httpPath(soundsModel.background.file)
    if soundsModel.on_enter?
      sounds.push type: 'effect', src: Sim.util.httpPath(soundsModel.on_enter)
    if sounds.length > 0
      cc.Loader.preload sounds, @_soundsLoaded, @


  _soundsLoaded: ->
    soundsModel = @menu.sounds
    if soundsModel.background?
      cc.AudioEngine.getInstance().playMusic Sim.util.httpPath(soundsModel.background.file),
        soundsModel.background.loop
    if soundsModel.on_enter?
      cc.AudioEngine.getInstance().playEffect Sim.util.httpPath(soundsModel.on_enter)


  getNumber: ->
    0


  next: ->
    @mainMenuLayer.readItMyself()
    true
