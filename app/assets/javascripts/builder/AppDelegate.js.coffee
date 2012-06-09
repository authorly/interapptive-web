window.Builder = main: ->
  # TODO: Show selected storybook's last edited scene's background
  # For now, we could just find, load and show the storybooks first scene
  #
  # Something like:
  #  var json = document.getElementById('json-data').value
  #  var storybook = new Sim.Storybook(json)
  #
  # Some other examples from r.w:
  #
  # pp = $("#sim-prev-page")
  # np.on "click", ->
  #   storybook.showNextPage()

cc = cc = cc or {}

cc.AppDelegate = cc.Application.extend(
  ctor: ->
    @_super()

  initInstance: ->
    true

  applicationDidFinishLaunching: ->
    pDirector = cc.Director.sharedDirector()
    pDirector.setDisplayFPS true
    pDirector.setAnimationInterval 1.0 / 60
    pScene = new cc.Scene()
    label = cc.LabelTTF.labelWithString("Scene Builder ready", "Arial", 24)
    label.setColor new cc.Color3B(255, 0, 0)
    s = pDirector.getWinSize()
    label.setPosition new cc.Point(s.width / 2, s.height / 2)
    pScene.addChild label
    pDirector.runWithScene pScene
    Builder.main()
    true

  applicationDidEnterBackground: ->
    cc.Director.sharedDirector().pause()

  applicationWillEnterForeground: ->
    cc.Director.sharedDirector().resume()
)