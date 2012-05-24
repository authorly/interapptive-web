class Helloworld extends cc.Layer

  constructor: ->
    super

    size = cc.Director.sharedDirector().getWinSize()

    # add a label shows "Hello World"
    # create and initialize a label
    @helloLb = cc.LabelTTF.labelWithString("Hello World", "Arial", 24)
    # position the label on the center of the screen
    @helloLb.setPosition(cc.ccp(cc.Director.sharedDirector().getWinSize().width / 2, 0))
    # add the label as a child to this layer
    @addChild(@helloLb, 5)

    # add "HelloWorld" splash screen"
    @pSprite = cc.Sprite.spriteWithFile("/assets/simulator/HelloWorld.png")
    @pSprite.setPosition(cc.ccp(cc.Director.sharedDirector().getWinSize().width / 2, cc.Director.sharedDirector().getWinSize().height / 2))
    @pSprite.setIsVisible(true)
    @pSprite.setAnchorPoint(cc.ccp(0.5, 0.5))
    @pSprite.setScale(0.5)
    @pSprite.setRotation(180)
    @addChild(@pSprite, 0)


    rotateToA = cc.RotateTo.actionWithDuration(2, 0)
    scaleToA = cc.ScaleTo.actionWithDuration(2, 1, 1)

    @pSprite.runAction(cc.Sequence.actions(rotateToA, scaleToA))

    @circle = new CircleSprite()
    @circle.setPosition(new cc.Point(40, 280))
    @addChild(@circle, 2)
    @circle.schedule(@circle.myUpdate, 1 / 60)

    @helloLb.runAction(cc.MoveBy.actionWithDuration(2.5, cc.ccp(0, 280)))

    @setIsTouchEnabled(true)

    return true


Helloworld.scene = ->
  scene = cc.Scene.node()
  scene.addChild(@node())

  return scene

Helloworld.node = ->
  return new this

window.Helloworld = Helloworld
