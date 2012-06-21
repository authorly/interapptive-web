#= require ./widget

class App.Builder.Widgets.TextWidget extends App.Builder.Widgets.Widget

  constructor: (options={}) ->
    super

    @_string = options.string

    @label = cc.LabelTTF.labelWithString(@_string, 'Arial', 24)

    @addChild(@label)
    @setContentSize(@label.getContentSize())

    @on('dblclick', @handleDoubleClick)


  getString: ->
    @_string

  setString: (string) ->
    @_string = string
    @label.setString(@_string)
    @setContentSize(@label.getContentSize())

  handleDoubleClick: (touch, event) =>
    @setString(window.prompt('Enter the new string', @_string) || '<No Text>')

    #input = $('<textarea>')
    #$(cc.canvas.parentNode).append(input)

    #r = @rect()

    #input.css(
    #  position: 'absolute'
    #  top: 100 + $(cc.canvas).position().top
    #  left: r.origin.x + $(cc.canvas).position().left
    #)
