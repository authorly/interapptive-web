## Rationale

Authorly isn't a normal MVC application. It's rather complex because there are multiple views displayed at the same time, and they all need to be updated at certain times--sometimes together, sometimes not together.

The problem is that triggering events usually occur deep inside an action. For instance, a keyframe change occurs during a click event on a keyframe view. We could encapsulate all the functionality within that click event, but the problem is that then bloats the keyframe, forces it out of any resemblance to SRP, and we can't reuse those actions if we need to trigger a keyframe change elsewhere (i.e. if we click a 'go to first keyframe' button.

The solution to this is relatively simple: move to a service-based archictecture.

## Services

A service is essentially a simple class that is invoked with some data (i.e. injected with its dependencies). It then acts as a sort of collection of disparate actions, connecting the received data with the objects that need to respond to the event. For exapmple:

``` coffee
class KeyframeView extends Backbone.view
  events:
    'click .keyframe': @switchKeyframe

  switchKeyframe:
    switcher = new SwitchKeyframeService(oldKeyframe, newKeyframe)
    switcher.execute
```

The huge advantage of this is that a service object is essentially a workflow object, which lets us codify functions of the application into discrete classes.
