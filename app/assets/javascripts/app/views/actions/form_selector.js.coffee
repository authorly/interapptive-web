class App.Views.ActionFormSelector extends Backbone.View
  template: JST["app/templates/actions/form_selector"]
  events:
    'change #action-list': 'changeActionDefinition'
  
  initialize: =>
    @activeDefinition   = @options.activeDefinition
    @actionDefinitions  = @options.actionDefinitions
    @disabled           = @options.disabled
    @parent             = @options.parent

  render: =>
    $(@el).html(
      @template(
        actionDefinitions: @actionDefinitions.models
        activeDefinition: @activeDefinition
        disabled: @disabled
      )
    )

    this

  changeActionDefinition: (e) =>
    selected      = $(e.currentTarget)
    definitionId  = $('option:selected', selected).val()
    @parent.trigger('change:actionDefinition', definitionId)
