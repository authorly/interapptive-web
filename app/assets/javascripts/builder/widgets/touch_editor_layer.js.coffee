#=require ./touch_editor
TouchEditor = App.Builder.Widgets.TouchEditor

class App.Builder.Widgets.TouchEditorLayer extends cc.Layer
  constructor: ->
    super
    @touchPoints = []
    @_capturedItem = null

    @setIsTouchEnabled(true)


    touchPoint = new TouchEditor(radius: 32)
    @addChild(touchPoint)
    touchPoint.setPosition(new cc.Point(100, 200))
    touchPoint.setOpacity(150)

    @touchPoints.push(touchPoint)

  itemAtTouch: (touch) ->
    @itemAtPoint(touch.locationInView())

  itemAtPoint: (point) ->
    for item in @_m_pChildren
      if item.getIsVisible()
        local = item.convertToNodeSpace(point)

        r = item.rect()
        r.origin = new cc.Point(0, 0)

        # Fix bug in cocos2d-html5; It doesn't convert to local space correctly
        local.x += @getAnchorPoint().x * r.size.width
        local.y += @getAnchorPoint().y * r.size.height

        if cc.Rect.CCRectContainsPoint(r, local)
          return item

    null

  ccTouchesBegan: (touches) ->
    item = @itemAtTouch(touches[0])
    return unless item

    touch = touches[0].locationInView()

    @_capturedItem = item
    @_previousPoint = new cc.Point(touch.x, touch.y)

    return true

  ccTouchesMoved: (touches) ->
    point = touches[0].locationInView()
    if @_capturedItem
      @moveCapturedItem(point)
    else
      @highlightItemAtPoint(point)

  moveCapturedItem: (point) ->
    @_previousPoint ||= point
    delta = cc.ccpSub(point, @_previousPoint)
    newPos = cc.ccpAdd(delta, @_capturedItem.getPosition())

    @_capturedItem.setPosition(newPos)
    @_previousPoint = new cc.Point(point.x, point.y)

  highlightItemAtPoint: (point) ->
    @unhighlightAllItems()

    item = @itemAtPoint(point)
    return unless item

    item.setOpacity(225)

  unhighlightAllItems: ->
    for item in @touchPoints
      item.setOpacity(150)

  ccTouchesEnded: (touches) ->
    @_previousPoint = null
    @_capturedItem = null

