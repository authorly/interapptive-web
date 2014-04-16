class Sim.Models.Action extends Sim.Models.Base

  @createFromJson: (json, kind) ->
    action = new Sim.Models.Action
      kind: kind
      tag: json.actionTag

    if json.duration?
      action.duration = json.duration

    if json.intensity?
      action.intensity = json.intensity

    if json.position?
      action.position = new cc.Point(json.position[0], json.position[1])

    if json.actions?
      action.actions = _.clone(json.actions)

    action
