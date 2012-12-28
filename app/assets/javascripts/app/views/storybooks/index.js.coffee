class App.Views.StorybookIndex extends Backbone.View
  template: JST["app/templates/storybooks/index"]
  events:
    'click          .storybook': 'storybookSelected'
    'click     .open-storybook': 'openStorybook'
    'click  .new-storybook-btn': 'showStorybookForm'
    'click              .close': 'closeStorybookForm'
    'submit    .storybook-form': 'createStorybook'
    'click   .delete-storybook': 'deleteStorybook'

  initialize: ->
    @collection.on('reset', @render, this)
    @collection.on('add', @appendStorybook, this)

  render: ->
    $(@el).html(@template())
    @collection.each (storybook) => @appendStorybook(storybook)
    $(".modal-body").removeClass("loading-book")

    if App.Config.environment == 'development' && @collection.length > 0
      @selectStorybook(@collection.at(0))
      @openStorybook()

    this

  appendStorybook: (storybook) ->
    view = new App.Views.Storybook(model: storybook)
    $('#storybook-list').prepend(view.render().el)

  createStorybook: (e) ->
    # Prevent page refresh
    e.preventDefault()
    attributes = title: $('.storybook-title').val()

    # Created a collection with attributes
    @collection.create attributes,
      wait: true
      success: (storybook, response)->
        $('.storybook-form')[0].reset()
        $('a.storybook').removeClass "active alert alert-info"
        $('a.storybook').first().addClass "active alert alert-info"
        $('.btn-primary.open-storybook').removeClass "disabled"

        App.currentStorybook(storybook)

        $('.storybook-form').fadeOut(130)
        $('.new-storybook-btn').delay(130).fadeIn(130)
      error: @handleErrors

  handleErrors: ->
    alert "Your storybook must have a title!"

  closeStorybookForm: ->
    $('.storybook-form').fadeOut(130)
    $('.new-storybook-btn').delay(130).fadeIn(130)

  showStorybookForm: ->
    $('.new-storybook-btn').fadeOut(70)
    $('.storybook-form').delay(70).fadeIn()

  openStorybook: ->
    storybookId = App.currentStorybook().get('id')
    return unless storybookId?

    $("#storybooks-modal").modal "hide"

    scenesIndex = App.sceneList()
    # XXX this should not be done here; this belongs to the model layer
    # it should be done on initialization
    scenesIndex.collection.storybook_id = App.currentStorybook().get('id')
    scenesIndex.collection.fetch() # Triggers a render.

    $('#scene-list').html scenesIndex.el

    $(".scene").removeClass "disabled"


  storybookSelected: (e) ->
    $('a.storybook').removeClass "active alert alert-info"
    $(e.currentTarget).addClass "active alert alert-info"
    $('.btn-primary.open-storybook').removeClass "disabled"
    storybook_id = $(e.currentTarget).data("id")

    @selectStorybook(@collection.get(storybook_id))


  selectStorybook: (storybook) ->
    App.currentStorybook(storybook)


  deleteStorybook: (e) ->
    e.preventDefault()
    storybook_id = $(e.currentTarget).data("id")
    storybook = @collection.get(storybook_id)
    message  =
      '\nYou are about to delete this storybook and all of it\'s scenes, keyframes, images, etc.\n\n\n' +
      'This cannot be undone.\n\n\n' +
      'Are you sure you want to continue?\n'

    if confirm(message) then storybook.destroy() and document.location.reload true

