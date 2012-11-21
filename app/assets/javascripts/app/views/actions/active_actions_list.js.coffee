class App.Views.ActiveActionsList extends Backbone.View
  tagName: 'ul'
  id:      'active-actions'
  events:
    'click .delete': 'delete'
    'click .edit':   'edit'

  initialize: =>
    @collection.on('reset', @render, this)
    @collection.on('add', @appendActionToList, this)

  declareAddActionListener: ->
    $('#active-actions-window .icon-plus').on 'click', ->
      $('#toolbar li ul li.actions').click()

  render: =>
    $(@el).empty()
    @collection.each (action) => @appendActionToList(action)
    @createAddActionEl()
    @initTooltips()
    @declareAddActionListener()
    this

  edit: (e) =>
    actionId = $(e.currentTarget).data('action-id')
    action =   @collection.get(actionId)

    @actionDefinitions = new App.Collections.ActionDefinitionsCollection()
    @actionDefinitions.fetch
      success: =>
        activeDefinition = @actionDefinitions.get(action.get('action_definition_id'))
        view = new App.Views.ActionFormContainer(
          action: action
          activeDefinition: activeDefinition
          actionDefinitions: @actionDefinitions
        )

        App.modalWithView(view: view).show()

  delete: (e) ->
    actionRowEl = $(e.currentTarget).closest('li')
    actionId =    $(e.currentTarget).data('action-id')
    action =      App.activeActionsCollection.get(actionId)
    deleteMsg =   'Are you sure you want to delete this action?\n'

    if confirm(deleteMsg)
      action.destroy
        success: => $(actionRowEl).remove()


  initTooltips: =>
    $el = $(@el)
    $el.find('div.action-image').tooltip(placement: 'bottom')
    $el.find('span.action-name').tooltip(placement: 'left')


  createAddActionEl: ->
    el = '<i class="icon-plus icon-black"></i>'
    $('#active-actions-window').append(el)


  appendActionToList: (action) =>
    actionView = new App.Views.Action(model: action)
    actionEl =   actionView.render().el

    $(@el).append(actionEl)


