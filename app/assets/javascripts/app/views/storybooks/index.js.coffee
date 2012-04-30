class App.Views.StorybookIndex extends Backbone.View
  # Referred via @template in render method below
  template: JST["app/templates/storybooks/index"]
  
  events:
    'click .storybook': 'selectStorybook'
    'click .open-storybook': 'openStorybook'
    
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
    
  render: ->
    # Render out Storybooks collection to our template
    $(@el).html(@template(storybooks: @collection))
    this