#
# The publishing area of Authorly is a means for authors to submit an app.
#
class App.Views.Publishing extends Backbone.View
  template: JST['app/templates/storybooks/publishing']

  render: ->
    @$el.html @template()

    info = new App.Models.ApplicationInformation({storybook: @model}, parse: true)
    @$('.modal-body').html('').append new App.Views.AbstractFormView(model: info).render().el

    @



  # events:
    # 'click .nav .availability': 'showAvailability'
    # 'click .nav .release-info': 'showReleaseInfo'

  # render: ->
    # @$el.html @template()

    # availabilty = new App.Views.Storybooks.AvailabilityForm
      # model: @model
    # @$('.modal-body .availability').html(availabilty.render().el)

    # releaseInfo = new App.Views.Storybooks.ReleaseInfoForm
      # model: @model
    # @$('.modal-body .release-info').html(releaseInfo.render().el)

    # @$('.nav .active').click()

    # @


  # showAvailability: ->
    # @$('.nav .availability').addClass('active').siblings().removeClass('active')
    # @$('.modal-body .availability').show().siblings().hide()


  # showReleaseInfo: ->
    # @$('.nav .release-info').addClass('active').siblings().removeClass('active')
    # @$('.modal-body .release-info').show().siblings().hide()
