# Rationale

Authorly is a one page app, perfectly suitable for a MVC implementation.

The problem with the current implementation is that it does not completely follow the MVC pattern, which we are going to fix.

# Stronger Model layer

We need a stronger model layer, that will form a (firm) foundation for the views. Goals for the M layer:

## Goal: have a model for each element that is persisted

Separating the information in a model has a couple of benefits: parsing and serializing the data (to be saved) is in one place (and easier to test); other models can work with this one (without depending on views being rendered, as MVC gods dictated); views and other entities can listen to events and update themselves (which we do by hand now, for widgets). etc.

Currently Widgets don't have a Backbone model, only the view implementation (from Builder). This complicates working with widgets, as they cannot exist without a view being rendered. We must have Backbone Models for Widgets.

Also, check if there are other views that have entities that should be models

## Goal: have all the relationships in the model layer

We should have all the necessary relationships modelled in Backbone:

* storybook.scenes, scene.storybook
* scene.keyframes, keyframe.scene
* scene.widgets, widget.scene
* keyframe.widgets, widget.keyframe
* same for texts, audio, video, etc

I recommend against using Backbone Relational to do this. I don't like how much 'magic' code it brings to the table. We should be able to accomplish this by passing parameters / maybe overriding Backbone's parse method / using the fact that any model added to a collection has a collection property pointing to that (e.g. if a KeyframesCollection instance knows which scene it belongs to, its elements can do @collection.scene to get the scene they belong to).

In implementing this check that the relationship information is already available when events (reset, add, etc) are triggered, so entities listening to these events find a complete object, with all the relationships.


## Goal: be totally independent of views

The model layer must be TOTALLY INDEPENDENT of views.

* we must be able to add only the models JS to the page, and play with it in the console and everything must work
* tests must work with only model JS included, no other view JS / global JS
* models must not use any reference to global variables that belong to the view layer (currentScene, currentKeyframe, etc)

Currently a lot of models depend on views, and this complicates life because they must be instantiated only after views exist (or, even worse, after a series of views were rendered and several methods called, elements rendered - e.g. currentKeyframe is available after the scene was rendered and the last element made active… a nightmare).

Remove all view dependencies from the model layer. Take care to remove the indirect ones as well (the ones through global vars).

The part that generates the JSON must belong to the model layer as well. It will listen to changes in the models and update the json accordingly.

## Goal: do not reuse collections

Reusing the same collection with in App.keyframeList() / App.keyframesCollection causes bugs. Because ajax calls return asynchronously, and their success/complete handlers operate directly on the 'currentX' collection, which was changed in the meantime through user actions.

Therefore: no collection reuse. Each scene will point to its own keyframesCollection. Each ajax request will be in the context of a scene/keyframe, and on return it will modify elements of that scene/keyframe, and not of the current one. This will be so joyous!


## Code smells

Each of the following should trigger a panicked reaction and a prompt refactoring:

* references to views or global things that depend on views, in the models
* complicated code to find a related model entity (the scene of a keyframe, the keyframe or scene of a widget, etc)
* model-like code in the views: ajax requests, serialization/deserialization (should be extracted to a model)
* many global variables. We should not have both currentScene and currentKeyframes (and/or currentWidgets etc). With the help of the stronger model layer, we should be able to do @current.get('scene').keyframes instead of currentKeyframes. Less variables to maintain, less opportunity for errors

# A better View layer

## Use Presentation Models

A problem with the current implementation is how to current[Scene/Keyframe/etc] is stored & changed. Currently we have methods that set this variable and tell explicitly tell each view to change.

A smarter implementation would use [Presentation Models](http://martinfowler.com/eaaDev/PresentationModel.html). This means that the currentX is a Backbone object, that contains

* contains the set/get part from Backbone
* includes the Backbone Events

To make it super simple, we can use Backbone Models (and we just don't use any of the synchronization code).

Benefits:

* there is only one global object that has attributes for currentScene / currentKeyframe
* when a view needs to change some currentX, it just sets it on the global object
* all interested views listen to changes in these attributes and update accordingly
* we get decoupling! we can add views that change when currentScene/currentKeyframe changes, without changing code in many places, just by making them listen


## Remove unnecessary coupling between views

Views should be independent of each other, and rely on events from models or presentation models to update.

The only exception is when a view is composed from other views, and its only role is to manage them. But most of our views are not like that. :)

Example: the toolbar currently invokes a lot of views and tells them explicitly what to do. It does not make sense to do that, since the implementation of the keyframes/scenes/scene views should be able to change without affecting the toolbar (which is not intrinsically linked to them).

There are two strategies:

### Listen to models

Example: ActiveWidgetList and WidgetLayer are super coupled (and it's not necessary at all). They both should depend on a WidgetsCollection and update themselves, independently, when the elements in the collection change.

The toolbar can add elements to the the current scene/keyframesCollection/keyframe (and the views will update accordingly since they listen to changes on these elements).

### Use the global vent

When totally unrelated views must 'communicate', instead of having them refer to each other explicitly, use the global vent.

Now this is used in order for the views that display the scene/keyframe to publish what actions are allowed on that element, and the toolbar listens and reacts to these events. This way, the scene/keyframe views are not coupled to the toolbar (and if we decide to change the toolbar implementation, we can do that without changing unrelated code).

## Cleanup

When a view is removed from the DOM, it should clean up after itself, by removing all the event listeners it added to the models. Having this now will help avoiding ugly memory leaks.

Use: [View.dispose](https://github.com/documentcloud/backbone/pull/1461)

Also check out this [so thread](http://stackoverflow.com/questions/8348805/pattern-to-manage-views-in-backbone) and this [blog post](http://lostechies.com/derickbailey/2011/09/15/zombies-run-managing-page-transitions-in-backbone-apps/) to understand more about the problem.

## Code smells

* views that refer to other views, invoke methods on them
* duplicating model data in the view (the views that show the widgets create their own array of widgets, and try to maintain it, and it's a duplicate of the collection they render)

## Also

Use the Backbone shortcuts for getting the jQuery selector for:

* the current element: `@$el` instead of `$(@el)`. It's shorted, sweeter, and also memoized (not calculated every time you use it)
* doing a jQuery selection within the current element: `@$('x')` instead of `$(@el).find('x')`. It's shorter and easier to understand.