class App.Views.StorybookIndex extends Backbone.View
  template: JST['app/templates/storybooks/index']
  DELETE_STORYBOOK_MSG =
    '\nYou are about to delete this storybook and all of its scenes, keyframes, and media\n\n\n' +
    'This cannot be undone.\n\n\n' +
    'Are you sure you want to continue?\n'

  events:
    'click  .storybook'         : 'storybookSelected'
    'click  .open-storybook'    : 'openStorybook'
    'click  .new-storybook-btn' : 'showStorybookForm'
    'click  .close'             : 'closeStorybookForm'
    'submit .storybook-form'    : 'createStorybook'
    'click  .delete-storybook'  : 'deleteStorybook'


  initialize: ->
    @collection.on 'add'  ,  @appendStorybook,  @
    @collection.on 'remove', @removeStorybook,  @
    @collection.on 'sync',   @storybooksLoaded, @
    @selectedStorybook = null


  render: ->
    @$el.html @template()
    @renderStorybooks()
    @


  # storybooks

  renderStorybooks: ->
    @$('#storybook-list').html('')
    @collection.each (storybook) => @appendStorybook(storybook)
    if App.Config.environment == 'development' && @collection.length > 0
      @selectStorybook @collection.at(@collection.length - 1)
      # @openStorybook(local: true)


  storybooksLoaded: ->
    @hideLoader()
    @renderStorybooks()


  createStorybook: (event) ->
    event.preventDefault()
    if App.currentUser.canMakeMoreStorybooks()
      App.vent.trigger('show:message', 'warning', "You are not allowed to create more than #{App.currentUser.get('allowed_storybooks_count')} storybooks.")
      return

    @collection.create { title: @$('.storybook-title').val() },
      wait:    true
      error:    -> App.vent.trigger('show:message', 'warning', 'Please properly fill in fields!')
      success: @closeStorybookForm


  appendStorybook: (storybook) ->
    view = new App.Views.Storybook(model: storybook)
    @$('#storybook-list').prepend(view.render().el)

    @selectStorybook storybook


  deleteStorybook: (event) ->
    event.preventDefault()

    if confirm(DELETE_STORYBOOK_MSG)
      storybook = @collection.get $(event.currentTarget).data('id')
      storybook.destroy()


  removeStorybook: (storybook) =>
    @$(".storybook[data-id=#{storybook.id}]").parent().remove()
    @enableOpenStorybookButton(false)


  storybookSelected: (event) ->
    event.preventDefault()

    id = $(event.currentTarget).data 'id'
    @selectStorybook @collection.get(id)


  selectStorybook: (storybook) ->
    @selectedStorybook = storybook

    @$('.storybook').removeClass('active alert alert-info').
      filter("[data-id=#{storybook.id}]").addClass('active alert alert-info')

    @enableOpenStorybookButton()


  openStorybook: (options={}) ->
    url = @selectedStorybook.baseUrl()
    if options.local
      window.location = url
    else
      window.open(url, '_blank')


  enableOpenStorybookButton: (enabling = true) ->
    el = @$('.btn-primary.open-storybook')
    if enabling
      el.removeClass('disabled')
    else
      el.addClass('disabled')


  hideLoader: ->
    @$('#storybook-loading').css('visibility', 'hidden')


  # storybook form

  showStorybookForm: ->
    @$('.new-storybook-btn').fadeOut(70)
    @$('.storybook-form').delay(70).fadeIn()
    window.setTimeout (=> @$('.storybook-form .storybook-title').focus()), 71


  closeStorybookForm: =>
    @$('.storybook-form input').val('')
    @$('.storybook-form').fadeOut(130)
    @$('.new-storybook-btn').delay(130).fadeIn(130)
