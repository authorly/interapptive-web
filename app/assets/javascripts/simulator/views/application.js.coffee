Sim.Views.StorybookApplication = cc.Application.extend
  config: document.ccConfig

  ctor: (storybook) ->
    @_super()
    @storybook = storybook

    cc.COCOS2D_DEBUG = @config['COCOS2D_DEBUG']
    cc.setup(@config['tag'])
    cc.AppController.shareAppController().didFinishLaunchingWithOptions()


  applicationDidFinishLaunching: ->
    @director = cc.Director.getInstance()
    # set FPS. the default value is 1.0/60 if you don't call this
    @director.setAnimationInterval(1.0 / @config['frameRate'])

    @mainMenuScene = new Sim.Views.MainMenuScene(@storybook.menu)
    cc.LoaderScene.preload [], =>
      @director.replaceScene(@mainMenuScene)

    true


  previousScene: ->
    currentScene = @director.getRunningScene()
    # return unless currentScene.back?

    # if currentScene.back()
    # else
      # @director?.popScene()
    @director?.popScene()


  next: ->
    currentScene = @director.getRunningScene()
    return unless currentScene.next?

    if currentScene.next()
    else
      @_showNextScene()


  home: ->
    @director.popToRootScene()


  setMode: (mode) ->
    if (mode == 'readItMyself')
      @mode = mode
      @_showNextScene()
    else
      alert("For now, only 'read it myself' works in Preview.")


  showKeyframe: (index) ->
    currentScene = @director.getRunningScene()
    currentScene.showKeyframe(index)


  _showNextScene: ->
    currentScene = @director.getRunningScene()
    currentScene.cleanup()

    number = currentScene.getNumber() + 1
    if (scene = @storybook.getScene(number))?
      @director.pushScene(new Sim.Views.Scene(scene, @storybook.homeMenu))
