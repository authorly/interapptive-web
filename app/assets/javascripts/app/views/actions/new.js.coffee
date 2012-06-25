class App.Views.NewAction extends Backbone.View
  events:
    'submit form': 'createAction'

  initialize: (options) ->
    @definition = @model.get('definition')

  createAction: (event) ->
    event.preventDefault()

    @form.commit()
    @model.save()

  render: ->
    $(@el).empty()
    schema = this.generateSchema()
    @form = new Backbone.Form(schema: schema, model: @model).render()
    $(@el).append @form.el

    @delegateEvents()
    this

  generateSchema: ->
    schema = {}

    _.each @definition.get('attribute_definitions'), (attribute, i) ->
      validationType = switch attribute.type
                       when 'integer' then /^[-+]?\d+$/
                       when 'decimal' then /^[-+]?\d*\.?\d+$/
                       when 'string'  then /^.+$/

      validationMessage = switch attribute.type
                          when 'integer' then 'Must be an integer.'
                          when 'decimal' then 'Must be a number.'
                          when 'string'  then ''

      validators = [
        {
          type: 'required'
          message: 'Required'
        }
        {
          type:   'regexp'
          regexp: validationType
          message: validationMessage
        }
      ]
      
      schema[attribute.name] = {
        type: 'Text'
        title: attribute.name
        validators: validators
      }

    return schema

  attributeToString: (attribute) ->
    attribute.name
