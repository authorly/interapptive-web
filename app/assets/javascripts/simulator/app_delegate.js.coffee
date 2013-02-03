#= require ./init

class Sim.AppDelegate extends cc.Application
  initInstance: ->
    true

  applicationDidFinishLaunching: ->
    # initialize director
    director = cc.Director.sharedDirector()

    # turn on display FPS
    director.setDisplayFPS(true)

    # set FPS. the default value is 1.0/60 if you don't call this
    director.setAnimationInterval(1.0 / 60)

    # Create initial empty scene
    scene = new cc.Scene()

    # run
    director.runWithScene(scene)

    return true
