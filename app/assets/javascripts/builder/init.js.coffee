# The main (and only) cocos2d scene of the application.
App.Builder.StorybookScene = cc.Scene.extend
  onEnter: ->
    @_super()

    @overflow = cc.LayerColor.create(new cc.c4b(190, 190, 190, 64))
    @widgets  = new App.Builder.Widgets.WidgetLayer(App.currentWidgets)
    @border   = new App.Builder.Widgets.WorkspaceBorderLayer()

    @addChild @overflow, 100, 10
    @addChild @widgets,  100, 11
    @addChild @border,   100, 12


# A cocos2d application that manages the builder canvas.
App.Builder.StorybookApplication = cc.Application.extend
  config: document.ccConfig

  ctor: (scene) ->
    @_super()
    @startScene = scene
    cc.COCOS2D_DEBUG = @config['COCOS2D_DEBUG']
    cc.setup(@config['tag'])
    cc.AppController.shareAppController().didFinishLaunchingWithOptions()


  applicationDidFinishLaunching: ->
    director = cc.Director.getInstance()
    # set FPS. the default value is 1.0/60 if you don't call this
    director.setAnimationInterval(1.0 / @config['frameRate'])

    cc.LoaderScene.preload [], =>
      director.replaceScene(new @startScene())

    true


App.Builder.init = ->
  App.storybookApplication = new App.Builder.StorybookApplication(App.Builder.StorybookScene)

  # remove the container that is forcibly added by cocos2d-html
  cocosContainer = $('#Cocos2dGameContainer')
  canvas = cocosContainer.find('canvas')
  cocosContainer.parent().append(canvas)
  cocosContainer.remove()
