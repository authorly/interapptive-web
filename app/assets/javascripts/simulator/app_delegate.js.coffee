class Sim.AppDelegate extends cc.Application
  initSimulator: (json) ->
    json ||= document.getElementById('json-data').value

    storybook = new Sim.Storybook(json)

    np = $('#sim-next-page')
    pp = $('#sim-prev-page')

    np.on('click', -> storybook.showNextPage())
    pp.on('click', -> storybook.showPreviousPage())

  initInstance: ->
    true

  applicationDidFinishLaunching: ->
    # initialize director
    director = cc.Director.sharedDirector()

    # turn on display FPS
    director.setDisplayFPS(true)

    # set FPS. the default value is 1.0/60 if you don't call this
    director.setAnimationInterval(1.0 / 60)

    # create a scene. it's an autorelease object
    scene = new cc.Scene()

    label = cc.LabelTTF.labelWithString("Simulator ready", "Arial", 24)
    label.setColor(new cc.Color3B(255, 0, 0))

    s = director.getWinSize()
    label.setPosition(new cc.Point(s.width / 2, s.height / 2))

    scene.addChild(label)

    # run
    director.runWithScene(scene)

    @initSimulator()

    return true

