class App.Views.StorybookIndex extends Backbone.View
  template: JST["app/templates/storybooks/index"]
  events:
    'click          .storybook': 'selectStorybook'
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
    $("#storybooks-modal").modal "hide" unless $('.open-storybook').hasClass "disabled"
    
    App.sceneList().collection.storybook_id = App.currentStorybook().get('id')
    App.sceneList().collection.fetch() # Triggers a render.
    $('#scene-list').html App.sceneList().el

    $(".scene").removeClass "disabled"

  selectStorybook: (e) ->
    $('a.storybook').removeClass "active alert alert-info"
    $(e.currentTarget).addClass "active alert alert-info"
    $('.btn-primary.open-storybook').removeClass "disabled"
    
    storybook_id = $(e.currentTarget).data("id")
    storybook = @collection.get(storybook_id)
    App.currentStorybook(storybook)

  deleteStorybook: (e) ->
    e.preventDefault()
    storybook_id = $(e.currentTarget).data("id")
    console.log "~~"
    console.log @collection
    storybook = @collection.get(storybook_id)
    message  =
      '\nYou are about to delete this storybook and all of it\'s scenes, keyframes, images, etc.\n\n\n' +
      'This cannot be undone.\n\n\n' +
      'Are you sure you want to continue?\n'

    if confirm(message) then storybook.destroy() and document.location.reload true
