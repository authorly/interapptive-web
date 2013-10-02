class App.Views.StorybookIndex extends Backbone.View
  template: JST['app/templates/storybooks/index']
  DELETE_STORYBOOK_MSG =
    '\nYou are about to delete this storybook and all of its scenes, keyframes, and media\n\n\n' +
    'This cannot be undone.\n\n\n' +
    'Are you sure you want to continue?\n'

  events:
    'click  .storybook'         : 'openStorybook'
    'click  .delete-storybook'  : 'deleteStorybook'

    'click  .new-storybook-btn' : 'showStorybookForm'
    'click  .close'             : 'closeStorybookForm'
    'submit .storybook-form'    : 'createStorybook'


  initialize: ->
    @collection.on 'add'  ,  @appendStorybook,  @
    @collection.on 'remove', @removeStorybook,  @
    @collection.on 'sync',   @storybooksLoaded, @


  render: ->
    @$el.html @template()
    @renderStorybooks()
    @


  # storybooks

  renderStorybooks: ->
    @$('#storybook-list').html('')
    @collection.each (storybook) => @appendStorybook(storybook)


  storybooksLoaded: ->
    @hideLoader()
    @renderStorybooks()


  createStorybook: (event) ->
    event.preventDefault()

    if App.signedInAsUser.canMakeMoreStorybooks()
      App.vent.trigger('show:message', 'warning', "You are not allowed to create more than #{App.signedInAsUser.get('allowed_storybooks_count')} storybooks.")
      return

    title = @$('.storybook-title').val()

    if App.signedInAsUser.hasStorybookWithTitle(title)
      App.vent.trigger('show:message', 'warning', "You can not create two storybooks with same title.")
      return

    @collection.create { title: title },
      wait:    true
      error:    -> App.vent.trigger('show:message', 'warning', 'Please properly fill in fields!')
      success:
        mixpanel.track "Created storybook"
        @closeStorybookForm


  appendStorybook: (storybook) ->
    view = new App.Views.Storybook(model: storybook)
    @$('#storybook-list').prepend(view.render().el)


  deleteStorybook: (event) ->
    event.preventDefault()
    if confirm(DELETE_STORYBOOK_MSG)
      storybook = @collection.get $(event.currentTarget).data('id')
      storybook.destroy
        success: -> mixpanel.track "Deleted a storybook"


  removeStorybook: (storybook) =>
    @$(".storybook[data-id=#{storybook.id}]").parent().remove()


  openStorybook: (event) ->
    event.preventDefault()

    mixpanel.track "Open storybook"

    id = $(event.currentTarget).data 'id'
    storybook = @collection.get(id)
    url = storybook.baseUrl()
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
    mixpanel.track "Show storybook form"

    @$('.new-storybook-btn').fadeOut(70)
    @$('.storybook-form').delay(70).fadeIn()
    window.setTimeout (=> @$('.storybook-form .storybook-title').focus()), 71


  closeStorybookForm: =>
    mixpanel.track "Hide storybook form"

    @$('.storybook-form input').val('')
    @$('.storybook-form').fadeOut(130)
    @$('.new-storybook-btn').delay(130).fadeIn(130)
