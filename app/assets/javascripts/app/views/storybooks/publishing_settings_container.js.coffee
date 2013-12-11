#
# The publishing area of Authorly is a means for authors to submit an app.
#
class App.Views.Publishing extends Backbone.View
  template: JST['app/templates/storybooks/publishing']

  render: ->
    @$el.html @template()

    @publishingView = new App.Views.PublishingForm(model: @model.application_information)
    @$('.modal-body').html('').append @publishingView.render().el

    @


  remove: ->
    @publishingView.remove()
    super

