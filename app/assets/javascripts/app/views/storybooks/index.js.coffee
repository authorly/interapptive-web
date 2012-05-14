class App.Views.StorybookIndex extends Backbone.View
  template: JST["app/templates/storybooks/index"]
  
  #
  # Listeners
  #
  events:
    'click .storybook': 'selectStorybook'
    'click .open-storybook': 'openStorybook'
    'click .new-storybook-btn': 'showStorybookForm'
    'click .close': 'closeStorybookForm'
    'submit .storybook-form': 'createStorybook'
  
  #
  # Fires upon class initializing
  #
  initialize: ->
    # Ensure our collection is rendered upon loading
    @collection.on('reset', @render, this)
    @collection.on('add', @appendStorybook, this)

  #
  # Render out Storybooks collection to our template
  #
  render: ->
    $(@el).html(@template())
    @collection.each(@appendStorybook)
    this

  #
  # Append storybook object to our modal list
  #
  appendStorybook: (storybook) ->
    view = new App.Views.Storybook(model: storybook)
    $('#storybook-list').prepend(view.render().el)
  
  #
  # Create storybook record from the inline form input (in modal)
  #
  createStorybook: (e) ->
    
    # Prevent page refresh
    e.preventDefault()
    
    # Variable for attributes, for neatness
    # May need to add current user here to be associated with the storybook
    attributes = title: $('.storybook-title').val()
    
    # Created a collection with attributes
    @collection.create attributes,
    
      # From the docs:
      #   Creating and destroying models is now optimistic.
      #   Pass {wait: true} if you need the previous behavior of waiting for the server to acknowledge success. 
      #   You can now also pass {wait: true} to save calls.
      wait: true
      
      # If storybook was successfully added to the database
      success: (storybook, response)-> 
        $('.storybook-form')[0].reset()
        
        # Adjust styles if new storybook was added, 
        # Remove other active states, apply active state to new storybook
        $('a.storybook').removeClass "active alert alert-info"
        $('a.storybook').first().addClass "active alert alert-info"
        $('.btn-primary.open-storybook').removeClass "disabled"

        # Set users currentStorybook
        App.currentStorybook(storybook)
        
        # Hide new storybook form and show button
        $('.storybook-form').fadeOut(130)
        $('.new-storybook-btn').delay(130).fadeIn(130)
        
      # Client-side error validation callback
      error: @handleError
  
  #
  # Client-side error validation callback definition
  #
  handleError: ->
    # Temporary filler - FIXME
    alert "Form input error"
    
  #  
  # Hides inline form for adding storybooks (in the modal)
  #
  closeStorybookForm: ->
    $('.storybook-form').fadeOut(130)
    $('.new-storybook-btn').delay(130).fadeIn(130)
    
  #
  # Shows inline form for adding storybooks (in the modal)
  #
  showStorybookForm: ->
  
    # Hide "Create New Storybook" button to replace with form
    $('.new-storybook-btn').fadeOut(70)
    
    # Show inline form on our modal for creating a new app
    $('.storybook-form').delay(70).effect "bounce",
      times: 3
    , 300 # Duration of effect in miliseconds
  
  #
  # Show slides & close modal for storybook after user has selected one
  #
  openStorybook: ->
    appSettingsView: new App.Views.AppSettings
      el: $('#storybook-settings')

    # Hide modal unless 'Open' button is disabled
    $("#storybooks-modal").modal "hide" unless $('.open-storybook').hasClass "disabled"
    
    # Get collection of scenes for chosen storybook 
    @scenesCollection = new App.Collections.ScenesCollection([], {storybook_id: App.currentStorybook().get("id")})
    
    # Retrieve data for objects
    @scenesCollection.fetch()
    
    # Load scene list/index for current storybook
    view = new App.Views.SceneIndex(collection: @scenesCollection)
    
    # Render view into scene list container
    $('#scene-list').html(view.render().el)
    
    # For draggable/sliding element on sidebar
    $(".scene-list").overscroll()
    $(".scene-list").css height: ($(window).height()) + "px"

    $(".scene").removeClass "disabled"

  #
  # When user clicks an item from the list of storybooks
  #
  selectStorybook: (e) ->

    # Remove active state CSS from siblings
    $('a.storybook').removeClass "active alert alert-info"
    
    # Changes clicked elements color
    $(e.currentTarget).addClass "active alert alert-info"

    # Remove disabled class from open button on modal 
    $('.btn-primary.open-storybook').removeClass "disabled"
    
    # Get the data-id attribute (storybook ID)
    storybook_id = $(e.currentTarget).data("id")
    
    # Get the object representing our storybook by ID
    storybook = @collection.get(storybook_id)

    # Set users currentStorybook to what they clicked 
    App.currentStorybook(storybook)
