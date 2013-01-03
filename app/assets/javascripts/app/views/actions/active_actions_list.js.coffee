
DELETE_ACTION_MSG =
  'Are you sure you want to delete this action?\n'


class App.Views.ActiveActionsList extends Backbone.View
  tagName: 'ul'

  el:      '#active-actions'

  events:
    'click .delete' : 'delete'
    'click .edit'   : 'edit'


  initialize: =>
    @collection.on 'reset', @render           , @
    @collection.on 'add', @appendActionToList , @


  declareAddActionListener: ->
    $('#active-actions-window .icon-plus').on 'click', ->
      $('#toolbar li ul li.actions').click()


  render: =>
    @$el.empty()
    @collection.each (action) => @appendActionToList(action)
    @createAddActionEl()
    @initTooltips()
    @declareAddActionListener()
    @


  edit: (event) =>
    action = @collection.get $(event.currentTarget).data('action-id')

    #
    # RFCTR
    #     Needs ventilation
    #
    #
    #     @actionDefinitions = new App.Collections.ActionDefinitionsCollection()
    #     @actionDefinitions.fetch
    #      success: =>
    #        activeDefinition = @actionDefinitions.get(action.get('action_definition_id'))
    #        view = new App.Views.ActionFormContainer(
    #          action: action
    #          activeDefinition: activeDefinition
    #          actionDefinitions: @actionDefinitions
    #        )
    #
    #        App.modalWithView(view: view).show()


  delete: (event) ->
    if confirm DELETE_ACTION_MSG
      action = App.activeActionsCollection.get $(e.currentTarget).data('action-id')
      action.destroy
        success: =>
          $(event.currentTarget).closest('li').remove()


  initTooltips: ->
    @$('div.action-image').tooltip(placement: 'bottom')
    @$('span.action-name').tooltip(placement: 'left')


  createAddActionEl: ->
    $('#active-actions-window').append('<i class="icon-plus icon-black"></i>')


  appendActionToList: (action) =>
    actionView = new App.Views.Action(model: action)
    actionEl =   actionView.render().el

    @$el.append(actionEl)


