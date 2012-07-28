# Monkey patch to fix bugs in cocos2d-html5 -- it can't add to DOM correctly
cc.setupHTML = (a) ->
  b = cc.canvas
  b.style.zIndex = 0
  c = cc.$new("div")
  c.id = "Cocos2dGameContainer"
  c.style.overflow = "hidden"
  c.style.width = b.clientWidth + "px"
  a && c.setAttribute("fheight", a.getContentSize().height)
  a = cc.$new("div")
  a.id = "domlayers"
  c.appendChild(a)
  b.parentNode.insertBefore(c, b)
  c.appendChild(b)

  return a

# Monkey patch to fix bug in touch calculation in cocos2d-html5
cc.Touch.prototype.locationInView = ->
  p = this._m_point


  # Ratio of canvas to element size
  ratioW = cc.canvas.width / $(cc.canvas).width()
  ratioH = cc.canvas.height / $(cc.canvas).height()

  # Fix coords ignoring scroll
  scrollV = 0
  scrollH = 0

  x = $(cc.canvas)
  while x.length > 0
    scrollV += x.scrollTop()
    scrollH += x.scrollLeft()

    x = x.parent()

  # X coord doesn't consider ratio
  realX = (p.x - scrollH) * ratioW

  # Y coord has wrong origin and doesn't consider ratio
  realY = (p.y - (cc.canvas.height - $(cc.canvas).height())) - scrollV
  realY *= ratioH

  actualPoint = new cc.Point(realX, realY)

  return actualPoint


# Cocos2d-html calls this a lot, but doesn't define it anywhere
cc.Log = cc.LOG = console.log.bind(console)
