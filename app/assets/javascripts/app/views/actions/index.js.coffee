class App.Views.ActionIndex extends Backbone.View
  template: JST["app/templates/actions/index"]
  events:
    'change select': 'switchAction'

  initialize: (options) ->
    @definitions = options.definitions

  render: (selectedDefinition) ->
    selectedDefinition ?= @definitions.first()

    $(@el).html @template(actions: @definitions.models)

    if selectedDefinition
      $(@el).find("option[value='#{selectedDefinition.id}']").attr('selected', 'selected')

    action = new App.Models.Action(definition: selectedDefinition)

    @formView = new App.Views.NewAction(model: action)
    @formView.render()
    $(this.el).append $(@formView.el)
    this

  switchAction: (event) ->
    field = $(event.currentTarget)
    definitionId = $("option:selected", field).val()
    definition = @definitions.get definitionId

    this.render(definition)
