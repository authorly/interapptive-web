#
# Application-wide settings for storybook where users can change
# app name, description price, icons, etc.
#
class App.Views.SettingsContainer extends Backbone.View
  template: JST['app/templates/storybooks/settings_container']


  events:
    'click .general-settings': '_showGeneralSettings'
    'click .icons':            '_showIconManager'


  render: ->
    @$el.html @template()
    @_showGeneralSettings()
    @


  _showGeneralSettings: ->
    @$('li.general-settings').addClass('active').siblings().removeClass('active')

    view = new App.Views.Storybooks.GeneralSettingsForm
      model: App.currentSelection.get('storybook')
    @$('.modal-body').html(view.render().el)


  _showIconManager: (event) ->
    @$('li.icons').addClass('active').siblings().removeClass('active')

    view = new App.Views.Storybooks.AppIcons
      storybook: App.currentSelection.get('storybook')
    @$('.modal-body').html(view.render().el)