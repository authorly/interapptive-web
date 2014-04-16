class Sim.Models.Text extends Sim.Models.Base

  @createFromJson: (json) ->
    new Sim.Models.Text
      string: json.text
      position: new cc.Point(json.xOffset, json.yOffset)
      anchor: _.clone(json.anchorPoint)
      font:
        size: json.fontSize
        name: Sim.util.normalizedFontName(json.fontType)
        color: new cc.Color3B(json.fontColor...)
        # highlight_color: _.clone(json.fontHighlightColor)
