class Sim.Views.HotspotsLayer extends cc.Layer

  constructor: (options) ->
    super

    @particlesFile = options.particlesDefinitionFile
    cc.SAXParser.getInstance().preloadPlist(@particlesFile)

    @setTouchMode(cc.TOUCH_ONE_BY_ONE)
    @setTouchEnabled(true)



  show: (hotspotsModel) ->
    @hotspotsModel = hotspotsModel
    for hotspot in hotspotsModel
      if hotspot.glitter
        particle = cc.ParticleSystem.create(@particlesFile)
        particle.setPosition hotspot.position
        particle.initWithTotalParticles(6)
        @addChild(particle)


  clear: ->
    @removeAllChildren()


  onTouchBegan: (touch, e)->
    @_itemForTouch(touch)?


  onTouchEnded: (touch, e) ->
    if (hotspot = @_itemForTouch(touch))?
      if (soundUrl = hotspot.soundUrl)?
        cc.AudioEngine.getInstance().playEffect soundUrl
      else
        alert 'Hotspot video not supported yet'


  _itemForTouch: (touch) ->
    touchLocation = touch.getLocation()
    for hotspot in @hotspotsModel
      return hotspot if hotspot.contains(touchLocation)
    null

