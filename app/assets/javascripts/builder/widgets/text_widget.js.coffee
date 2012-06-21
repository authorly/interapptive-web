#= require ./widget

class App.Builder.Widgets.TextWidget extends App.Builder.Widgets.Widget

  constructor: (options={}) ->
    super

    @labels = []

    label = cc.LabelTTF.labelWithString(options.string, 'Arial', 24)

    @addChild(label)
    @setContentSize(label.getContentSize())


  draw: (ctx) ->
