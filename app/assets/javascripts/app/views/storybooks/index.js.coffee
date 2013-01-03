
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
    @collection.on 'add'  , @appendStorybook, @
    @collection.on 'reset', @render         , @


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
    $('#storybook-list').prepend view.render().el


  createStorybook: (event) ->
    event.preventDefault()

    @collection.create
      title   : $('.storybook-title').val(),
      wait    : true
      error   : -> alert 'Please properly fill in fields!'
      success : (storybook, response) ->
        $('.storybook-form')[0].reset().fadeOut(130)
        $('.new-storybook-btn').delay(130).fadeIn(130)
        $('.btn-primary.open-storybook').removeClass 'disabled'
        $('a.storybook').removeClass('active alert alert-info').first().addClass 'active alert alert-info'

        App.currentStorybook(storybook)


  closeStorybookForm: ->
    $('.storybook-form').fadeOut(130)
    $('.new-storybook-btn').delay(130).fadeIn(130)


  showStorybookForm: ->
    $('.new-storybook-btn').fadeOut(70)
    $('.storybook-form').delay(70).fadeIn()


  openStorybook: ->
    return unless App.currentStorybook().get 'id'

    # XXX this should not be done here; this belongs to the model layer
    # it should be done on initialization
    scenesIndex = App.sceneList()
    scenesIndex.collection.storybook_id = App.currentStorybook().get 'id'
    scenesIndex.collection.fetch() # Triggers a render.

    $('#scene-list').html(scenesIndex.el)
    $('#storybooks-modal').modal 'hide'
    $('.scene').removeClass 'disabled'


  storybookSelected: (event) ->
    $(event.currentTarget).addClass 'active alert alert-info'
    $('a.storybook').removeClass 'active alert alert-info'
    $('.btn-primary.open-storybook').removeClass 'disabled'

    id = $(event.currentTarget).data 'id'
    @selectStorybook @collection.get(id)


  selectStorybook: (storybook) ->
    App.currentStorybook(storybook)


  deleteStorybook: (event) ->
    event.preventDefault()

    if confirm DELETE_STORYBOOK_MSG
      storybook = @collection.get $(event.currentTarget).data('id')
      storybook.destroy()
      document.location.reload(true)

