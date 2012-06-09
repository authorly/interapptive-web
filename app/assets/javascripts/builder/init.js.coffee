cc = cc = cc or {}
cc.Dir = "../cocos2d/"
cc.loadQue = []
cc.COCOS2D_DEBUG = 2
cc._DEBUG = 1
cc._IS_RETINA_DISPLAY_SUPPORTED = 0
cc.$ = (x) ->
  document.querySelector x

cc.$new = (x) ->
  document.createElement x

cc.Log = cc.LOG = console.log.bind(console)

cc.TransitionScene = ->

window.runBuilder = ->
  cc.setupHTML = (a) ->
    b = cc.canvas
    b.style.zIndex = 0
    c = cc.$new("div")
    c.id = "Cocos2dGameContainer"
    c.style.overflow = "hidden"
    c.style.height = b.clientHeight + "px"
    c.style.width = b.clientWidth + "px"
    a and c.setAttribute("fheight", a.getContentSize().height)
    a = cc.$new("div")
    a.id = "domlayers"
    c.appendChild a
    b.parentNode.insertBefore c, b
    c.appendChild b
    a

  cc.Touch::locationInView = ->
    p = @_m_point
    ratioW = cc.canvas.width / $(cc.canvas).width()
    ratioH = cc.canvas.height / $(cc.canvas).height()
    scrollV = 0
    scrollH = 0
    x = $(cc.canvas)
    while x.length > 0
      scrollV += x.scrollTop()
      scrollH += x.scrollLeft()
      x = x.parent()
    realX = (p.x - scrollH) * ratioW
    realY = (p.y - (cc.canvas.height - $(cc.canvas).height())) - scrollV
    realY *= ratioH
    actualPoint = new cc.Point(realX, realY)
    actualPoint

  cc.setup "builder-canvas"

  console.log "Something working"

  # Shown during initial preloading of images for builder
  # i.e., last edited scene's background images
  cc.Loader.shareLoader().onloading = ->
    cc.LoaderScene.shareLoaderScene().draw()

  cc.Loader.shareLoader().onload = ->
    cc.AppController.shareAppController().didFinishLaunchingWithOptions()

  cc.Loader.shareLoader().preload [
    type: "image"
    src: "/assets/simulator/HelloWorld.png"
  ,
    type: "image"
    src: "/assets/simulator/grossini_dance_07.png"
  ]