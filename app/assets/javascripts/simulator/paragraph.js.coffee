WORD_SPACING = 8

class Sim.Paragraph extends cc.Node

  fontColor: '#000'
  fontHighlightColor: '#f00'
  fontSize: 20
  fontName: 'Helvetica'

  constructor: (info) ->
    @info = info
    @labels = []

  createLabels: ->
    # FIXME -- loading new fonts?
    @fontName = 'Arial' # FIXME Forced to arial for now

    @info.linesOfText.forEach (line) =>
      xOffset = line.xOffset
      yOffset = line.yOffset

      j = 0
      words = line.words()
      while j < words.length
        # Reuse nextLabel if we created it for measuring
        if nextLabel
          label = nextLabel
        else
          label = new cc.LabelTTF()
          label.initWithString(
            words[j]
            @fontName
            @fontSize
          )

        label.setPosition(new cc.Point(xOffset, yOffset))

        @labels.push(label)
        @addChild(label)

        # If not the last word on line...
        if j < words.length - 1
          nextLabel = new cc.LabelTTF()
          nextLabel.initWithString(
            words[j + 1]
            @fontName
            @fontSize
          )
          # ...increase offset to account for the next word in the line
          xOffset += label.getContentSize().width / 2 + nextLabel.getContentSize().width / 2 + WORD_SPACING
        else
          nextLabel = null
        j++

  onEnter: ->
    super
    @createLabels() if @labels.length == 0

  highlightWord: (index) ->
    i = 0
    while i < @labels.length
      label = @labels[i]
      label.setColor(if (i is index - 1) then @fontHighlightColor else @fontColor)
      i++

  startHighlight: ->
    @_highlightedLabel = 0
    @_highlightDuration = 0
    @unscheduleUpdate()
    @scheduleUpdate()
    @highlightWord(1)

  stopHighlight: ->
    @unscheduleUpdate()
    @highlightWord(0)

  update: (dt) ->
    @_highlightDuration += dt
    i = @labels.length

    while i >= @_highlightedLabel
      if @info.highlightingTimes[i] < @_highlightDuration
        unless i is @_highlightedLabel
          @_highlightedLabel = i
          @highlightWord(i + 1)
        break
      i--


