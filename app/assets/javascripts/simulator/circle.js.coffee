class window.CircleSprite extends cc.Sprite
  constructor: ->
    super

    @_radians = 0

  draw: ->
      cc.renderContext.fillStyle = "rgba(255,255,255,1)";
      cc.renderContext.strokeStyle = "rgba(255,255,255,1)";

      if (@_radians < 0)
          @_radians = 360
      cc.drawingUtil.drawCircle(
        cc.PointZero()
        30
        cc.DEGREES_TO_RADIANS(@_radians)
        60
        true
      )


  myUpdate: (dt) ->
      @_radians -= 6

