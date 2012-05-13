class App.Views.StorybookIndex extends Backbone.View
  template: JST["app/templates/storybooks/index"]

  events:
    'click .storybook': 'selectStorybook'
    'click .open-storybook': 'openStorybook'
    'click .new-storybook-btn': 'showStorybookForm'
    'click .close': 'closeStorybookForm'
    'submit .storybook-form': 'createStorybook'
  
  initialize: ->
    @collection.on('reset', @render, this)
    @collection.on('add', @appendStorybook, this)

  render: ->
    $(@el).html(@template())
    @collection.each (storybook) => @appendStorybook(storybook)
    return this

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
        
      # Client-side error validation callback
      error: @handleErrors

  handleErrors: ->
    alert "Your storybook must have a title!"

  closeStorybookForm: ->
    $('.storybook-form').fadeOut(130)
    $('.new-storybook-btn').delay(130).fadeIn(130)

  showStorybookForm: ->
    $('.new-storybook-btn').fadeOut(70)
    $('.storybook-form').delay(70).effect "bounce",
      times: 3
    , 300 # Duration of effect in miliseconds

  openStorybook: ->
    $("#storybooks-modal").modal "hide" unless $('.open-storybook').hasClass "disabled"
    
    App.sceneList().collection.storybook_id = App.currentStorybook().get('id')
    App.sceneList().collection.fetch() # Triggers a render.
    $('#scene-list').html App.sceneList().el

    $(".scene-list").overscroll()
    $(".scene-list").css height: ($(window).height()) + "px"
    $(".scene").removeClass "disabled"

  selectStorybook: (event) ->
    $('a.storybook').removeClass "active alert alert-info"
    $(event.currentTarget).addClass "active alert alert-info"
    $('.btn-primary.open-storybook').removeClass "disabled"
    
    storybook_id = $(event.currentTarget).data("id")
    storybook = @collection.get(storybook_id)
    App.currentStorybook(storybook)
