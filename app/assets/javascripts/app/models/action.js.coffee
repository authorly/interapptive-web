class App.Models.Action extends Backbone.DeepModel
  paramRoot: 'action'

  validationTypeForAttribute: (attribute) ->
    validationType = switch attribute.type
        when 'integer' then /^[-+]?\d+$/
        when 'decimal' then /^[-+]?\d*\.?\d+$/
        when 'string'  then /^.+$/

  validationMessageForAttribute: (attribute) ->
    validationMessage = switch attribute.type
      when 'integer' then 'Must be an integer.'
      when 'decimal' then 'Must be a number.'
      when 'string'  then ''

  # Okay, this is super hacky, but it's necessary at least for the time being.
  # The problem here is that when we have a new object, we load our action
  # definition from its collection. That means that accessing the attribute
  # definitions must occur through its @get method (i.e. it's not made
  # available through the simple accessor.
  #
  # When we load an existing action, though, we're loading it from
  # the action, which Rails returns a JSON object to that will cause
  # the direct attribute to be set instead of putting it inside of
  # attributes.
  #
  # I'm not sure what the best way to rectify this is, but this works for now.
  # There should be a better way for sure, though -- our data structures simply
  # must be more consistant. I guarantee this will cause problems in the future.
  #
  # -- Rob
  #
  attributeDefinitions: () =>
    if @isNew()
      @get('action_definition').get('attribute_definitions')
    else
      @get('action_definition.attribute_definitions')

  actionAttributes: () =>
    @get('action_attributes')

  schemaForAttributes: =>
    schema = {}
    for attribute in @attributeDefinitions()
      schema["action_attributes.#{attribute.name}.value"] = {
        type: 'Text',
        title: attribute.name
        validators: [
          {
            type: 'required',
            message: 'Required'
          },
          {
            type: 'regexp',
            regexp: @validationTypeForAttribute(attribute),
            message: @validationMessageForAttribute(attribute),
          }
        ]
      }

    unless @isNew()
      @fieldValues = {}
      for attribute in @actionAttributes()
        @fieldValues["action_attributes.#{attribute.attribute_definition.name}.value"] = attribute.value

    schema


  url: =>
    if @isNew()
      '/scenes/' + App.currentScene().get('id') + '/actions.json'
    else
      "/scenes/" + App.currentScene().get('id') + "/actions/#{@get('id')}.json"

  toString: =>
    "Action"

class App.Collections.ActionsCollection extends Backbone.Collection
  model: App.Models.Action

  url: ->
    "/scenes/#{App.currentScene().get('id')}/actions.json"
