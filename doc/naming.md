# Naming events

Events have a default scope - the object on which they are triggered.
This is typically either a model object (Backbone Model or Collection) or the vent. The vent will be used only by views, to decouple views from each other.

Sometimes it also makes sense to trigger events on a view; for example a reusable view, like the Image Selector, triggers 'select' when the user chose an image, and then the master view, who needs the selector, listens for that event and acts appropriately.

The guideline for naming our custom events is:

For models:
* if it makes sense, and it's not ambiguous, use only a verb. Backbone follows this convention, triggering `sync`, `change`, `destroy` etc. on models, and `add`,  `remove`, `reset` etc. on collections.
* if more granularity is needed, use the convention `verb:noun`. Backbone triggers, for example, 'change:scale', 'change:position'.

For the vent and other views:
The rule `verb:noun` still holds. However, since a lot of different things pass through the vent, we should use scopes to group them. The syntax I propose is `scope-verb:noun`
For example:
`App.vent.trigger 'modal-create'
`App.vent.trigger 'audio-align'
`@trigger 'mouse-move'

Deciding whether to introduce a scope to group multiple actions, using the form `scope-verb:optionalNoun`, or to use the simple form, `verb:optionalNoun`, is not very obvious. I think we should use scopes only when multiple events have the same domain (like modals, and mouse events).

In all cases, if even more granularity is needed, put other parameters in the options hash. For example:
`App.vent.trigger 'create:widget', type: 'HotspotWidget'`

