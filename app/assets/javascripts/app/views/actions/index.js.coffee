class App.Views.ActionIndex extends Backbone.View
  template: JST["app/templates/actions/index"]
  events:
    'change select': 'switchAction'

  initialize: (options) ->
    @formView = options.formView
    @actions = options.actions

  render: (selectedAction) ->
    selectedAction ?= @actions.first()

    $(@el).html @template(actions: @actions.models)
    $(@el).find("option[value='#{selectedAction.id}']").attr('selected', 'selected')

    @formView.render()
    $(this.el).append $(@formView.el)
    this

  switchAction: (event) ->
    field = $(event.currentTarget)
    definitionId = $("option:selected", field).val()
    definition = @actions.get definitionId

    action = new App.Models.Action
          definition: definition

    @formView.model = action
    @formView.definition = action.get('definition')
    console.log @formView.model
    console.log @formView.definition
    this.render(definition)
