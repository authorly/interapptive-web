class Sim.Views.TextsLayer extends cc.Layer

  constructor: ->
    super
    @WORD_SPACING = cc.Director.getInstance().getContentScaleFactor() * 1.5


  show: (texts) ->
    for text in texts
      continue if text.string == ''
      @_show(text)


  clear: ->
    @removeAllChildren()


  _show: (text) ->
    lines = text.string.split("\n")
    yOffset = text.position.y

    for line in lines
      # words = line.split(' ')
      # C++-like split by whitespace - keeps the space next to each word
      words = line.match(/[^ ]*( |$)/g); words.pop()

      fontSize = text.font.size

      xOffset = text.position.x

      labels = []
      for word, index in words
        label = cc.LabelTTF.create(word, text.font.name, fontSize)
        label.setColor(text.font.color)

        # 0.85 seems the right anchor point to display the text the same as in the web editor @dira 2014/03/14
        label.setAnchorPoint(new cc.Point(0.0, 0.85))
        label.setPosition(new cc.Point(xOffset, yOffset))

        @addChild(label)
        labels.push(label)

        xOffset += label.getContentSize().width + @WORD_SPACING

      xAnchor = text.anchor[0]
      if xAnchor != 0
          totalWidth = (xOffset - text.position.x) - @WORD_SPACING
          dx = -totalWidth * xAnchor

          for label in labels
            position = label.getPosition()
            label.setPosition(new cc.Point(position.x + dx, position.y))

      yOffset -= fontSize
