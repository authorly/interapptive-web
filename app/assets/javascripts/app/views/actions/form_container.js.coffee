class App.Views.ActionFormContainer extends Backbone.View
  template:  JST["app/templates/actions/form_container"]
  id:        'action-form-container'
  events:
    'submit form': 'submit'

  initialize: ->
    @actionDefinitions = @options.actionDefinitions
    @activeDefinition = @options.activeDefinition ? @actionDefinitions.first()
    @action = @options.action ? new App.Models.Action(action_definition_id: @activeDefinition.id, action_definition: @activeDefinition)

    @selectorView = new App.Views.ActionFormSelector(
      actionDefinitions: @actionDefinitions
      activeDefinition: @activeDefinition
      disabled: !@action.isNew()
      parent: this
    ).render()

    @bind("change:actionDefinition", @actionDefinitionChange)

  render: =>
    $(@el).html(@template(title: if @action.isNew() then "Create a New Action" else "Edit Action"))
    @renderSelector()
    @renderForm()
    this

  renderSelector: =>
    $(@el).find('#actions').html(@selectorView.el)

  renderForm: =>
    @formView = new App.Views.ActionFormForm(
      action: @action
      activeDefinition: @activeDefinition
      parent: this
    ).render()

    $(@el).find('.modal-body').html(@formView.el)
    @delegateEvents()

  ################################################################################
  #
  # Events
  #
  ################################################################################

  actionDefinitionChange: (definitionId) =>
    @activeDefinition = @actionDefinitions.get(definitionId)
    @action = new App.Models.Action(action_definition_id: @activeDefinition.id, action_definition: @activeDefinition)
    @renderForm()

  submit: (e) =>
    e.preventDefault()
    errors = @formView.form.commit()
    unless errors
      @formView.form.model.save {},
        success: (model, response) =>
          App.activeActionsCollection.add(model)
          App.modalWithView().hide()
