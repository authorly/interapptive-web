class App.Views.ActionFormSelector extends Backbone.View
  template: JST['app/templates/actions/form_selector']

  events:
    'change #action-list': 'changeActionDefinition'
  
  initialize: =>
    @activeDefinition   = @options.activeDefinition
    @actionDefinitions  = @options.actionDefinitions
    @disabled           = @options.disabled
    @parent             = @options.parent


  render: =>
    @$el.html(
      @template(
        actionDefinitions: @actionDefinitions.models
        activeDefinition: @activeDefinition
        disabled: @disabled
      )
    )

    @


  changeActionDefinition: (event) =>
    definitionId  = $('option:selected', $(event.currentTarget)).val()
    @parent.trigger('change:actionDefinition', definitionId)
