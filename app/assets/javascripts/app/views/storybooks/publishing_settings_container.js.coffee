#
# The publishing area of Authorly is a means for authors to submit an app.
#
class App.Views.Publishing extends Backbone.View
  template: JST['app/templates/storybooks/publishing']

  render: ->
    @$el.html @template()

    if @model.publish_request?
      @view = new App.Views.PublishingInformation
        model: @model.publish_request
        tagName: 'div'
    else
      @view = new App.Views.PublishingForm(model: @model.application_information)

    @$('.modal-body').html('').append @view.render().el
    @


  remove: ->
    @view.remove()
    super

