class App.Models.ActionAttribute extends Backbone.Model
  paramRoot: 'action_attribute'


class App.Collections.ActionAttributesCollection extends Backbone.Collection
  model: App.Models.ActionAttribute

  initialize: (models, options) ->
    if options
      @action_id = options.action_id

  url: ->
    '/actions/{@action_id}/attributes.json'
