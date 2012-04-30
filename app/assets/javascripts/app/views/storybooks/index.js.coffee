class App.Views.StorybookIndex extends Backbone.View
  # Referred via @template in render method below
  template: JST["app/templates/storybooks/index"]
  
  events:
    'click .storybook': 'selectStorybook'
    'click .open-storybook': 'openStorybook'
    'click .new-storybook-btn': 'showStorybookForm'
    'click .close': 'closeStorybookForm'
    'submit .storybook-form': 'createStorybook'
    
  initialize: ->
    # Ensure our collection is rendered upon loading
    @collection.on('reset', @render, this)
    @collection.on('add', @appendStorybook, this)

  # Render out Storybooks collection to our template
  render: ->
    $(@el).html(@template())
    @collection.each(@appendStorybook)
    this

  appendStorybook: (storybook) ->
    view = new App.Views.Storybook(model: storybook)
    $('#storybook-list').prepend(view.render().el)
    
  createStorybook: (e) ->
    e.preventDefault()
    attributes = title: $('.storybook-title').val()
    @collection.create attributes,
      wait: true
      success: (storybook, response)-> 
        $('.storybook-form')[0].reset()
        
        # Adjust styles if new storybook was added, 
        # Remove other active states, apply active state to new storybook
        $('a.storybook').removeClass "active alert alert-info"
        $('a.storybook').first().addClass "active alert alert-info"
        $('.btn-primary.open-storybook').removeClass "disabled"

        # Set users currentStorybook
        App.currentStorybook(storybook)
      error: @handleError
      
  handleError: ->
    alert "Form input error"
    
  closeStorybookForm: ->
    $('.storybook-form').fadeOut(130)
    $('.new-storybook-btn').delay(130).fadeIn(130)
  
  showStorybookForm: ->
    $('.new-storybook-btn').fadeOut(70)
    $('.storybook-form').delay(70).effect "bounce",
      times: 3
    , 300
  
  openStorybook: ->
    # Hide modal unless 'Open' button is disabled
    $("#myStorybooksModal").modal "hide" unless $('.open-storybook').hasClass "disabled"
    

  # When user clicks an item from the list of storybooks
  selectStorybook: (e) ->

    # Get the data-id attribute of our sender
    storybook_id = $(e.currentTarget).data("id")
    
    # Remove active state CSS from siblings
    $('a.storybook').removeClass "active alert alert-info"
    
    # Changes clicked elements color
    $(e.currentTarget).addClass "active alert alert-info"

    # Remove disabled class from open button on modal 
    $('.btn-primary.open-storybook').removeClass "disabled"
    
    # Get the object representing our storybook by ID
    storybook = @collection.get(storybook_id)

    # Set users currentStorybook to what they clicked 
    App.currentStorybook(storybook)