class App.Views.StorybookIndex extends Backbone.View
  # Referred via @template in render method below
  template: JST["app/templates/storybooks/index"]
  
  events:
    'click .storybook': 'selectStorybook'
    'click .open-storybook': 'openStorybook'
    'click .new-storybook-btn': 'showStorybookForm'
    'click .close': 'closeStorybookForm'
    'submit .storybook-form': 'addStorybook'
    
  addStorybook: (e) ->
    e.preventDefault()
    @collection.create title: $('#storybook-title').val()
  
  closeStorybookForm: ->
    $('.storybook-form').fadeOut(70)
    $('.new-storybook-btn').delay(70).fadeIn(70)
  
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
    $(e.currentTarget).siblings().removeClass "active alert alert-info"
    
    # Changes clicked elements color
    $(e.currentTarget).addClass "active alert alert-info"

    # Remove disabled class from open button on modal 
    $('.btn-primary.open-storybook').removeClass "disabled"
    
    # Get the object representing our storybook by ID
    storybook = @collection.get(storybook_id)

    # Set users currentStorybook to what they clicked 
    App.currentStorybook(storybook)
    
  initialize: ->
    # Ensure our collection is rendered upon loading
    @collection.on('reset', @render, this)
    @collection.on('add', @render, this)
    
  render: ->
    # Render out Storybooks collection to our template
    $(@el).html(@template(storybooks: @collection))
    this