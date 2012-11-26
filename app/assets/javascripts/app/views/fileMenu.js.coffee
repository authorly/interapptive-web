class App.Views.FileMenuView extends Backbone.View
  events:
    'click .switch-storybook':          'switchStorybook'
    'click .show-storybook-settings':   'showSettings'
    'click .about-authorly':            'showAbout'
    'click .show-storybook-icons':      'showAppIcons'
    'click .compile-storybook':         'compileStorybook'

  render: ->
    $el = $(this.el)

  switchStorybook: ->
    document.location.reload true

  showSettings: ->
    view = new App.Views.Storybooks.SettingsForm()
    App.modalWithView(view: view).show()

  showAbout: ->
    view = new App.Views.AboutView()
    App.modalWithView(view: view).show()

  showAppIcons: ->
    view = new App.Views.Storybooks.AppIcons(collection: App.imagesCollection)
    App.modalWithView(view: view).show()
    view.fetchImages()

  compileStorybook: ->
    $.post('/compiler',
      storybook_json: App.storybookJSON.toString()
      storybook_id: App.currentStorybook().id
      ->
        console.log('enqueued for compilation')
    'json')
