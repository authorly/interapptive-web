class Sim.Models.Scene extends Sim.Models.Base

  @createFromJson: (json) ->
    parser = new Sim.Models.ActionParser(json.API)
    parser.run()

    scene = new Sim.Models.Scene
      number: json.Page.settings.number

      backgroundMusic: _.clone(json.Page.settings.backgroundMusicFile)

      sprites: _.map json.API.CCSprites, (spriteJson) ->
        sprite = Sim.Models.Sprite.createFromJson(spriteJson)
        sprite.action = parser.spriteActions[spriteJson.spriteTag]
        sprite

      keyframes: _.map json.Page.text.paragraphs, (keyframeJson, keyframeIndex) ->
        texts: _.map keyframeJson.linesOfText, (textJson) ->
          Sim.Models.Text.createFromJson(textJson)
        hotspots: _.map keyframeJson.hotspots, (hotspotJson) ->
          Sim.Models.Hotspot.createFromJson(hotspotJson)
        # spriteOrientations: {}
        swipeActions: parser.swipes[keyframeIndex+1]


      introDuration: parser.getIntroDuration()


    # for sprite in scene.sprites
      # lastOrientation = {}
      # for keyframe, keyframeIndex in scene.keyframes
        # orientation = {}
        # if keyframeIndex == 0
          # orientation = sprite.finalOrientation
        # else
          # swipes = keyframe.swipeActions
          # if swipes? && swipes[sprite.tag]?
            # orientation = swipes[sprite.tag].finalOrientation

        # orientation = _.extend {}, lastOrientation, orientation
        # keyframe.spriteOrientations[sprite.tag] = orientation

        # lastOrientation = orientation

    # scene
