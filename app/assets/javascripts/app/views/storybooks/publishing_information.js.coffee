class App.Views.PublishingInformation extends Backbone.View
  template: JST['app/templates/storybooks/publishing_information']
  ENGINES: [
    ['itunes',          'iTunes'],
    ['google_play',     'Google Play'],
    ['amazon_appstore', 'Amazon Appstore']
  ]

  render: ->
    applications = @model.get('applications')

    @$el.html @template(
      available:   @_getAvailable(applications)
      unavailable: @_getUnavailable(applications)
    )
    @


  _getAvailable: (applications) ->
    available = _.map @ENGINES, ([key, name]) =>
      if (application = @_getApplication(applications, key))?
        [name, application.url]
      else
        null
    _.compact(available)


  _getUnavailable: (applications) ->
    unavailable = _.map @ENGINES, ([key, name]) =>
      if @_getApplication(applications, key)? then null else [name]
    _.compact unavailable


  _getApplication: (applications, provider) ->
    _.find applications, (application) ->
      application.provider == provider
