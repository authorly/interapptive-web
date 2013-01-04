
DELETE_STORYBOOK_MSG =
  '\nYou are about to delete this storybook and all of it\'s scenes, keyframes, images, etc.\n\n\n' +
  'This cannot be undone.\n\n\n' +
  'Are you sure you want to continue?\n'


class App.Views.StorybookIndex extends Backbone.View
  template: JST['app/templates/storybooks/index']

  events:
    'click  .storybook'         : 'storybookSelected'
    'click  .open-storybook'    : 'openStorybook'
    'click  .new-storybook-btn' : 'showStorybookForm'
    'click  .close'             : 'closeStorybookForm'
    'submit .storybook-form'    : 'createStorybook'
    'click  .delete-storybook'  : 'deleteStorybook'


  initialize: ->
    @collection.on 'add'  ,  @appendStorybook, @
    @collection.on 'remove', @removeStorybook, @
    @collection.on 'reset',  @render         , @
    @selectedStorybook = null


  render: ->
    @$el.html @template()
    @collection.each (storybook) => @appendStorybook(storybook)
    $('.modal-body').removeClass 'loading-book'

    if App.Config.environment == 'development' && @collection.length > 0
      @selectStorybook @collection.at(0)
      @openStorybook()

    @


  appendStorybook: (storybook) ->
    view = new App.Views.Storybook(model: storybook)
    @$('#storybook-list').prepend view.render().el

    @selectStorybook storybook


  createStorybook: (event) ->
    event.preventDefault()

    @collection.create { title   : @$('.storybook-title').val() },
      wait:    true
      error:    -> alert 'Please properly fill in fields!'
      success: @closeStorybookForm


  closeStorybookForm: =>
    @$('.storybook-form input').val('')
    @$('.storybook-form').fadeOut(130)
    @$('.new-storybook-btn').delay(130).fadeIn(130)


  showStorybookForm: ->
    @$('.new-storybook-btn').fadeOut(70)
    @$('.storybook-form').delay(70).fadeIn()
    window.setTimeout (=> @$('.storybook-form .storybook-title').focus()), 71


  openStorybook: ->
    return unless @selectedStorybook?

    $('#storybooks-modal').modal 'hide'

    # XXX this should not be done here; this belongs to the model layer
    # it should be done on initialization
    scenesIndex = App.sceneList()
    scenesIndex.collection.storybook_id = @selectedStorybook.get 'id'
    scenesIndex.collection.fetch() # Triggers a render.

    # these initialization statements belong to the view that renders the scenes
    $('#scene-list').html(scenesIndex.el)
    $('.scene').removeClass 'disabled'


  storybookSelected: (event) ->
    id = $(event.currentTarget).data 'id'
    @selectStorybook @collection.get(id)


  selectStorybook: (storybook) ->
    @selectedStorybook = storybook

    @$('.storybook').removeClass('active alert alert-info').
      filter("[data-id=#{storybook.id}]").addClass('active alert alert-info')
    @$('.btn-primary.open-storybook').removeClass 'disabled'



  deleteStorybook: (event) ->
    event.preventDefault()

    if confirm(DELETE_STORYBOOK_MSG)
      storybook = @collection.get $(event.currentTarget).data('id')
      storybook.destroy()


  removeStorybook: (storybook) ->
    @$(".storybook[data-id=#{storybook.id}]").parent().remove()
